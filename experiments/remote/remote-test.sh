arrivalRate=$1
ClientBatchSize=$2
ProxyBatchSize=$3

Controller="54.94.113.24:8070"
RCFolder="/home/ubuntu/rabia"
NServers=5
NFaulty=2
NClients=5

ClientTimeout=60 # test duration
ProxyBatchTimeout=5
RC_Peers_N="54.94.113.24:10090,54.178.123.123:10091,13.233.14.202:10092,3.1.5.83:10093,34.247.105.45:10094"

output_path="logs/rabia/${arrivalRate}/${ClientBatchSize}/${ProxyBatchSize}/"

Rabia_Path="/rabia/rabia"

remote_log_path="/home/ubuntu/rabia/"

cert="/home/pasindu/Documents/rabia/experiments/remote/private_key_aws/pasindu2023.pem"

replica1=ubuntu@ec2-54-94-113-24.sa-east-1.compute.amazonaws.com
replica2=ubuntu@ec2-54-178-123-123.ap-northeast-1.compute.amazonaws.com
replica3=ubuntu@ec2-13-233-14-202.ap-south-1.compute.amazonaws.com
replica4=ubuntu@ec2-3-1-5-83.ap-southeast-1.compute.amazonaws.com
replica5=ubuntu@ec2-34-247-105-45.eu-west-1.compute.amazonaws.com

client1=ubuntu@ec2-15-228-241-95.sa-east-1.compute.amazonaws.com
client2=ubuntu@ec2-18-181-182-155.ap-northeast-1.compute.amazonaws.com
client3=ubuntu@ec2-3-108-41-221.ap-south-1.compute.amazonaws.com
client4=ubuntu@ec2-54-179-70-76.ap-southeast-1.compute.amazonaws.com
client5=ubuntu@ec2-3-249-212-182.eu-west-1.compute.amazonaws.com

rm -r ${output_path}; mkdir -p ${output_path}

echo "Removed old log files"

kill_command="pkill rabia ; pkill rabia; pkill rabia;"

sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${replica1} "${kill_command}"
sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${replica2} "${kill_command}"
sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${replica3} "${kill_command}"
sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${replica4} "${kill_command}"
sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${replica5} "${kill_command}"

sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${client1} "${kill_command}"
sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${client2} "${kill_command}"
sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${client3} "${kill_command}"
sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${client4} "${kill_command}"
sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${client5} "${kill_command}"

echo "killed previous running instances"

sleep 2

export_command="export LogFilePath=${remote_log_path} RC_Ctrl=${Controller} RC_Folder=${RCFolder} RC_LLevel="warn" Rabia_ClosedLoop=false Rabia_NServers=${NServers} Rabia_NFaulty=${NFaulty} Rabia_NClients=${NClients} Rabia_NConcurrency=1 Rabia_ClientBatchSize=${ClientBatchSize} Rabia_ClientTimeout=${ClientTimeout} Rabia_ClientThinkTime=0 Rabia_ClientNRequests=0 Rabia_ClientArrivalRate=${arrivalRate} Rabia_ProxyBatchSize=${ProxyBatchSize} Rabia_ProxyBatchTimeout=${ProxyBatchTimeout} Rabia_NetworkBatchSize=0 Rabia_NetworkBatchTimeout=0 RC_Peers=${RC_Peers_N} Rabia_StorageMode=0"

echo "starting replicas"

svr_export="export RC_Role=svr RC_Index=0 RC_SvrIp="54.94.113.24" RC_PPort="9090" RC_NPort="10090""
nohup sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} -n -f ${replica1} "${svr_export} && ${export_command} && .${Rabia_Path}" >${output_path}0.log &

svr_export="export RC_Role=svr RC_Index=1 RC_SvrIp="54.178.123.123" RC_PPort="9091" RC_NPort="10091""
nohup sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} -n -f ${replica2} "${svr_export} && ${export_command} &&  .${Rabia_Path}" >${output_path}1.log &

svr_export="export RC_Role=svr RC_Index=2 RC_SvrIp="13.233.14.202" RC_PPort="9092" RC_NPort="10092""
nohup sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} -n -f ${replica3} "${svr_export} && ${export_command} &&  .${Rabia_Path}" >${output_path}2.log &

svr_export="export RC_Role=svr RC_Index=3 RC_SvrIp="3.1.5.83" RC_PPort="9093" RC_NPort="10093""
nohup sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} -n -f ${replica4} "${svr_export} && ${export_command} &&  .${Rabia_Path}" >${output_path}3.log &

svr_export="export RC_Role=svr RC_Index=4 RC_SvrIp="34.247.105.45" RC_PPort="9094" RC_NPort="10094""
nohup sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} -n -f ${replica5} "${svr_export} && ${export_command} &&  .${Rabia_Path}" >${output_path}4.log &

sleep 5

echo "Starting client[s]"

cli_export="export RC_Role=cli RC_Index=0 RC_Proxy="54.94.113.24:9090""
nohup sshpass ssh -o "StrictHostKeyChecking no"   -i ${cert} -n -f ${client1} "${cli_export} && ${export_command} && .${Rabia_Path}" >${output_path}5.log &

cli_export="export RC_Role=cli RC_Index=1 RC_Proxy="54.178.123.123:9091""
nohup sshpass ssh -o "StrictHostKeyChecking no"   -i ${cert} -n -f ${client2} "${cli_export} && ${export_command} && .${Rabia_Path}" >${output_path}6.log &

cli_export="export RC_Role=cli RC_Index=2 RC_Proxy="13.233.14.202:9092""
nohup sshpass ssh -o "StrictHostKeyChecking no"   -i ${cert} -n -f ${client3} "${cli_export} && ${export_command} && .${Rabia_Path}" >${output_path}7.log &

cli_export="export RC_Role=cli RC_Index=3 RC_Proxy="3.1.5.83:9093""
nohup sshpass ssh -o "StrictHostKeyChecking no"   -i ${cert} -n -f ${client4} "${cli_export} && ${export_command} && .${Rabia_Path}" >${output_path}8.log &

cli_export="export RC_Role=cli RC_Index=4 RC_Proxy="34.247.105.45:9094""
nohup sshpass ssh -o "StrictHostKeyChecking no"   -i ${cert} -n -f ${client5} "${cli_export} && ${export_command} && .${Rabia_Path}" >${output_path}9.log &

echo "starting controller"

crl_export="export RC_Role=ctrl"
nohup sshpass ssh -o "StrictHostKeyChecking no"    -i ${cert} -n -f ${replica1} "${crl_export} && ${export_command} && .${Rabia_Path}" >${output_path}10.log &

sleep 100

echo "Completed Client[s]"

sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${replica1} "${kill_command}"
sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${replica2} "${kill_command}"
sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${replica3} "${kill_command}"
sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${replica4} "${kill_command}"
sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${replica5} "${kill_command}"

sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${client1} "${kill_command}"
sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${client2} "${kill_command}"
sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${client3} "${kill_command}"
sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${client4} "${kill_command}"
sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} ${client5} "${kill_command}"

sleep 10

echo "Finish test"