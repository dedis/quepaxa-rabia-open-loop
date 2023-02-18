import os


def run(arrivalRate, ClientBatchSize, ProxyBatchSize, ProxyBatchTimeout):
    os.system("/bin/bash /home/pasindu/Documents/rabia/experiments/local/local-consensus-rabia-test.sh "+ " "
              + str(arrivalRate) + " "
              + str(ClientBatchSize) + " "
              + str(ProxyBatchSize) + " "
              + str(ProxyBatchTimeout) + " ")

# case 1
arrivalRate=1000
ClientBatchSize=1
ProxyBatchSize=1
ProxyBatchTimeout=1 # milli seconds
run(arrivalRate, ClientBatchSize, ProxyBatchSize, ProxyBatchTimeout)


# case 2
arrivalRate=20000
ClientBatchSize=50
ProxyBatchSize=50
ProxyBatchTimeout=2 # milli seconds
run(arrivalRate, ClientBatchSize, ProxyBatchSize, ProxyBatchTimeout)


# case 3
arrivalRate=60000
ClientBatchSize=50
ProxyBatchSize=50
ProxyBatchTimeout=2 # milli seconds
run(arrivalRate, ClientBatchSize, ProxyBatchSize, ProxyBatchTimeout)