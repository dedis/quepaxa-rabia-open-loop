# A simple test that tests rabia by sending client requests
arrivalRate=$1

go build

Rabia_Path="rabia"
Controller="localhost:8070"
RCFolder="/home/pasindu/Documents/rabia/logs/"
NServers=3
NFaulty=1
NClients=3
ClientBatchSize=50
ProxyBatchSize=50
ClientTimeout=60 # test duration
ProxyBatchTimeout=5
RC_Peers_N="localhost:10090,localhost:10091,localhost:10092"

rm -r logs/ ; mkdir logs/

# export variables

export RC_Ctrl=${Controller} RC_Folder=${RCFolder} RC_LLevel="warn" Rabia_ClosedLoop=false
export Rabia_NServers=${NServers} Rabia_NFaulty=${NFaulty} Rabia_NClients=${NClients} Rabia_NConcurrency=1
export Rabia_ClientBatchSize=${ClientBatchSize} Rabia_ClientTimeout=${ClientTimeout} Rabia_ClientThinkTime=0 Rabia_ClientNRequests=0 Rabia_ClientArrivalRate=${arrivalRate}
export Rabia_ProxyBatchSize=${ProxyBatchSize} Rabia_ProxyBatchTimeout=${ProxyBatchTimeout} Rabia_NetworkBatchSize=0 Rabia_NetworkBatchTimeout=0
export RC_Peers=${RC_Peers_N} LogFilePath="logs/" Rabia_StorageMode=0

# kill previously running instances
for i in 1 2 3 4 5 6 7 8 9 10; do
  pkill rabia
done

# start servers
export RC_Role=svr RC_Index=0 RC_SvrIp="localhost" RC_PPort="9090" RC_NPort="10090"
nohup ./${Rabia_Path} >${RCFolder}0.log &
export RC_Role=svr RC_Index=1 RC_SvrIp="localhost" RC_PPort="9091" RC_NPort="10091"
nohup ./${Rabia_Path} >${RCFolder}1.log &
export RC_Role=svr RC_Index=2 RC_SvrIp="localhost" RC_PPort="9092" RC_NPort="10092"
nohup ./${Rabia_Path} >${RCFolder}2.log &

# start clients
export RC_Role=cli RC_Index=0 RC_Proxy="localhost:9090"
nohup ./${Rabia_Path} >${RCFolder}3.log &
export RC_Role=cli RC_Index=1 RC_Proxy="localhost:9091"
nohup ./${Rabia_Path} >${RCFolder}4.log &
export RC_Role=cli RC_Index=2 RC_Proxy="localhost:9092"
nohup ./${Rabia_Path} >${RCFolder}5.log &

# start controller
export RC_Role=ctrl
nohup ./${Rabia_Path} >${RCFolder}6.log &

sleep 10

# crash recovery script
nohup python3 experiments/python/crash-recovery-test.py logs/0.log logs/1.log logs/2.log >${RCFolder}python-consensus-crash.log &
echo "started crash recovery script"

sleep 80

# kill instances
for i in 1 2 3 4 5 6 7 8 9 10; do
  pkill rabia
done

echo "finish test"