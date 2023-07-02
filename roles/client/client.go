/*
   Copyright 2021 Rabia Research Team and Developers

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

package client

import (
	"fmt"
	"log"
	"math"
	"math/rand"
	"os"
	. "rabia/internal/config"
	"rabia/internal/logger"
	. "rabia/internal/message"
	"rabia/internal/rstring"
	"rabia/internal/system"
	"rabia/internal/tcp"
	"strconv"
	"sync"
	"time"

	"github.com/montanaflynn/stats"
	"github.com/rs/zerolog"
)

/*
	A clients sends one or more requests (i.e., DB read or write operations) at a time, we note down the send time and
	receive time in the following data structure
*/
type BatchedCmdLog struct {
	SendTime    time.Time     // the send time of this client-batched command
	ReceiveTime time.Time     // the receive time of client-batched command
	Duration    time.Duration // the calculate latency of this command (ReceiveTime - SendTime)
	Sent        bool          // whether this slot is sent or not
}

/*
	A Rabia client
*/
type Client struct {
	ClientId uint32
	Done     chan struct{}

	TCP     *tcp.ClientTCP
	Rand    *rand.Rand
	Logger  zerolog.Logger // the real-time server log that help to track throughput and the number of connections
	LogFile *os.File       // the log file that should be called .Sync() method before the routine exits

	CommandLog               []BatchedCmdLog
	SentSoFar, ReceivedSoFar int
	receiveMutex             *sync.Mutex

	arrivalRate     int        // requests per second poisson rate as specified
	arrivalTimeChan chan int64 // channel which stores the new arrival times
	arrivalChan     chan bool  // channel that triggers new open loop requests

	startTime time.Time

	window int
}

/*
	Initialize a Rabia client
*/
func ClientInit(clientId uint32, proxyIp string, arrivalRate int) *Client {
	zerologger, logFile := logger.InitLogger("client", clientId, 0, "both")
	c := &Client{
		ClientId: clientId,
		Done:     make(chan struct{}),

		TCP:     tcp.ClientTcpInit(clientId, proxyIp),
		Rand:    rand.New(rand.NewSource(time.Now().UnixNano() * int64(clientId))),
		Logger:  zerologger,
		LogFile: logFile,

		CommandLog:      make([]BatchedCmdLog, 0),
		SentSoFar:       0,
		ReceivedSoFar:   0,
		receiveMutex:    &sync.Mutex{},
		arrivalRate:     arrivalRate,
		arrivalTimeChan: make(chan int64, 1000000),
		arrivalChan:     make(chan bool, 1000000),
		window:          1000,
	}

	pid := os.Getpid()
	fmt.Printf("initialized client %v with process id: %v \n", c.ClientId, pid)

	return c
}

/*
	1. start the OS signal listener
	2. establish the TCP connection with a designated proxy
	3. starts a terminal logger
*/
func (c *Client) Prologue() {
	go system.SigListen(c.Done) //
	c.TCP.Connect()
	// go c.terminalLogger()
}

/*
	1. close the Done channel to inform other routines who listen to this signal to exit
	2. write a concluding log to file
	3. close the log file
	4. close the TCP connection
*/
func (c *Client) Epilogue() {
	close(c.Done)
	c.writeToLog()
	if err := c.LogFile.Sync(); err != nil {
		panic(err)
	}
	c.TCP.Close()
}

/*
	The main body of an open-loop client.
*/

func (c *Client) OpenLoopClient() {
	c.startTime = time.Now()
	c.generateArrivalTimes()

	go func() {
		i := 0
		for true {
			numRequests := 0
			for numRequests < Conf.ClientBatchSize {
				_ = <-c.arrivalChan // keep collecting new requests arrivals
				numRequests++
			}
			c.receiveMutex.Lock()
			if c.SentSoFar-c.ReceivedSoFar > c.window*Conf.ClientBatchSize {
				c.receiveMutex.Unlock()
				continue
			}
			c.receiveMutex.Unlock()
			c.sendOneRequest(i)
			i++
		}

	}()

	go func() {
		for true {
			rep := <-c.TCP.RecvChan
			c.processOneReply(rep)
		}
	}()

	c.startScheduler()           // this runs in the main loop
	time.Sleep(20 * time.Second) // for inflight requests
}

/*
	Until the test duration is arrived, fetch new arrivals and inform the request generator thread
*/

func (c *Client) startScheduler() {
	start := time.Now()

	for time.Now().Sub(start).Nanoseconds() < Conf.ClientTimeout.Nanoseconds() { // run until test completion
		nextArrivalTime := <-c.arrivalTimeChan

		for time.Now().Sub(start).Nanoseconds() < nextArrivalTime {
			// busy waiting until the time to dispatch this request arrives
		}
		c.arrivalChan <- true
	}
}

/*
	Generates Poisson arrival times in a separate thread
*/

func (c *Client) generateArrivalTimes() {
	go func() {
		lambda := float64(c.arrivalRate) / (1000.0 * 1000.0 * 1000.0) // requests per nano second
		arrivalTime := 0.0

		for true {
			// Get the next probability value from Uniform(0,1)
			p := rand.Float64()

			//Plug it into the inverse of the CDF of Exponential(_lamnbda)
			interArrivalTime := -1 * (math.Log(1.0-p) / lambda)

			// Add the inter-arrival time to the running sum
			arrivalTime = arrivalTime + interArrivalTime

			c.arrivalTimeChan <- int64(arrivalTime)
		}
	}()
}

/*
	Sends a single request.
	val is a string of 17 bytes (modifiable through Conf.KeyLen and Conf.ValLen)
	[0:1]   (1 byte): "0" == a write operation,  "1" == a read operation
	[1:9]  (8 bytes): a string Key
	[9:17] (8 bytes): a string Value
*/
func (c *Client) sendOneRequest(i int) {
	obj := Command{CliId: c.ClientId, CliSeq: uint32(i), Commands: make([]string, Conf.ClientBatchSize)}
	for j := 0; j < Conf.ClientBatchSize; j++ {
		val := fmt.Sprintf("%d%v%v", c.Rand.Intn(2),
			rstring.RandString(c.Rand, Conf.KeyLen),
			rstring.RandString(c.Rand, Conf.ValLen))
		obj.Commands[j] = val
	}
	for len(c.CommandLog) <= i+1000 { // create new entries
		c.CommandLog = append(c.CommandLog, BatchedCmdLog{
			SendTime:    time.Time{},
			ReceiveTime: time.Time{},
			Duration:    0,
			Sent:        false,
		})
	}
	c.CommandLog[i].SendTime = time.Now()
	c.CommandLog[i].Sent = true

	c.TCP.SendChan <- obj
	c.SentSoFar += Conf.ClientBatchSize
}

/*
	Processes on received reply
*/
func (c *Client) processOneReply(rep Command) {
	if c.CommandLog[rep.CliSeq].Duration != time.Duration(0) {
		panic("already received")
	}
	c.CommandLog[rep.CliSeq].ReceiveTime = time.Now()
	c.CommandLog[rep.CliSeq].Duration = c.CommandLog[rep.CliSeq].ReceiveTime.Sub(c.CommandLog[rep.CliSeq].SendTime)
	c.ReceivedSoFar += Conf.ClientBatchSize
}

/*
	Converts int[] to float64[]
*/

func (c *Client) getFloat64List(list []int64) []float64 {
	var array []float64
	for i := 0; i < len(list); i++ {
		array = append(array, float64(list[i]))
	}
	return array
}

const CLIENT_TIMEOUT = 2000000

/*
	Calculate stats
*/
func (c *Client) writeToLog() {

	f, err := os.Create(Conf.LogFilePath + Conf.Id + ".txt") // log file
	if err != nil {
		fmt.Print("Error creating the output log file")
		log.Fatal(err)
	}
	defer f.Close()

	var latencyList []int64 // contains the time duration spent for each successful request in micro seconds
	noResponses := 0        // number of requests for which no response was received
	totalRequests := 0      // total number of requests sent
	responses := 0

	for i := 0; i < len(c.CommandLog); i++ {
		if c.CommandLog[i].Sent == true { // if this slot was used before
			if c.CommandLog[i].Duration != 0 { // if we got a response
				if c.CommandLog[i].Duration.Microseconds() < CLIENT_TIMEOUT {
					latencyList = c.addValueNToArrayMTimes(latencyList, c.CommandLog[i].Duration.Microseconds(), Conf.ClientBatchSize)
					c.printRequests(i, c.CommandLog[i].SendTime.Sub(c.startTime).Microseconds(), c.CommandLog[i].ReceiveTime.Sub(c.startTime).Microseconds(), f)
					responses += Conf.ClientBatchSize
				} else {
					latencyList = c.addValueNToArrayMTimes(latencyList, CLIENT_TIMEOUT, Conf.ClientBatchSize)
					c.printRequests(i, c.CommandLog[i].SendTime.Sub(c.startTime).Microseconds(), c.CommandLog[i].SendTime.Sub(c.startTime).Microseconds()+CLIENT_TIMEOUT, f)
				}
			} else { // no response
				noResponses += Conf.ClientBatchSize
				latencyList = c.addValueNToArrayMTimes(latencyList, CLIENT_TIMEOUT, Conf.ClientBatchSize)
				c.printRequests(i, c.CommandLog[i].SendTime.Sub(c.startTime).Microseconds(), c.CommandLog[i].SendTime.Sub(c.startTime).Microseconds()+CLIENT_TIMEOUT, f)
			}
			totalRequests += Conf.ClientBatchSize
		}
	}

	medianLatency, _ := stats.Median(c.getFloat64List(latencyList))
	percentile99, _ := stats.Percentile(c.getFloat64List(latencyList), 99.0) // tail latency
	throughput := float64(responses) / Conf.ClientTimeout.Seconds()
	errorRate := (totalRequests - responses) * 100 / totalRequests

	fmt.Printf("Throughput := %v requests per second  ", throughput)
	fmt.Printf("\nMedian Latency := %v micro seconds per request ", medianLatency)
	fmt.Printf("\n99 pecentile latency := %v micro seconds per request ", percentile99)
	fmt.Printf("\nError Rate := %v \n", float64(errorRate))
}

/*
	Add value N to list, M times
*/

func (c *Client) addValueNToArrayMTimes(list []int64, N int64, M int) []int64 {
	for i := 0; i < M; i++ {
		list = append(list, N)
	}
	return list
}

/*
	Print a client request batch with arrival time and end time w.r.t test start time
*/

func (c *Client) printRequests(j int, startTime int64, endTime int64, f *os.File) {
	for i := 0; i < Conf.ClientBatchSize; i++ {
		_, _ = f.WriteString(strconv.FormatInt(int64(j), 10) + "." + strconv.FormatInt(int64(i), 10) + "," + strconv.Itoa(int(startTime)) + "," + strconv.Itoa(int(endTime)) + "\n")
	}
}
