arrivalRate=$1
ClientBatchSize=$2
ProxyBatchSize=$3

Controller="34.224.78.11:8070"
RCFolder="/home/ubuntu/rabia"
NServers=5
NFaulty=2
NClients=5

ClientTimeout=60 # test duration
ProxyBatchTimeout=5
RC_Peers_N="34.224.78.11:10090,18.207.143.224:10091,54.90.145.152:10092,184.72.141.58:10093,54.91.91.186:10094"

output_path="logs/rabia/${arrivalRate}/${ClientBatchSize}/${ProxyBatchSize}/"

Rabia_Path="/rabia/rabia"

remote_log_path="/home/ubuntu/rabia/"

cert="/home/pasindu/Documents/rabia/experiments/remote/private_key_aws/pasindu2023.pem"

replica1=ubuntu@ec2-34-224-78-11.compute-1.amazonaws.com
replica2=ubuntu@ec2-18-207-143-224.compute-1.amazonaws.com
replica3=ubuntu@ec2-54-90-145-152.compute-1.amazonaws.com
replica4=ubuntu@ec2-184-72-141-58.compute-1.amazonaws.com
replica5=ubuntu@ec2-54-91-91-186.compute-1.amazonaws.com

client1=ubuntu@ec2-3-95-239-214.compute-1.amazonaws.com
client2=ubuntu@ec2-34-239-247-39.compute-1.amazonaws.com
client3=ubuntu@ec2-54-227-84-218.compute-1.amazonaws.com
client4=ubuntu@ec2-54-82-109-207.compute-1.amazonaws.com
client5=ubuntu@ec2-3-87-78-76.compute-1.amazonaws.com

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

svr_export="export RC_Role=svr RC_Index=0 RC_SvrIp="34.224.78.11" RC_PPort="9090" RC_NPort="10090""
nohup sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} -n -f ${replica1} "${svr_export} && ${export_command} && .${Rabia_Path}" >${output_path}0.log &

svr_export="export RC_Role=svr RC_Index=1 RC_SvrIp="18.207.143.224" RC_PPort="9091" RC_NPort="10091""
nohup sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} -n -f ${replica2} "${svr_export} && ${export_command} &&  .${Rabia_Path}" >${output_path}1.log &

svr_export="export RC_Role=svr RC_Index=2 RC_SvrIp="54.90.145.152" RC_PPort="9092" RC_NPort="10092""
nohup sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} -n -f ${replica3} "${svr_export} && ${export_command} &&  .${Rabia_Path}" >${output_path}2.log &

svr_export="export RC_Role=svr RC_Index=3 RC_SvrIp="184.72.141.58" RC_PPort="9093" RC_NPort="10093""
nohup sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} -n -f ${replica4} "${svr_export} && ${export_command} &&  .${Rabia_Path}" >${output_path}3.log &

svr_export="export RC_Role=svr RC_Index=4 RC_SvrIp="54.91.91.186" RC_PPort="9094" RC_NPort="10094""
nohup sshpass ssh -o "StrictHostKeyChecking no"  -i ${cert} -n -f ${replica5} "${svr_export} && ${export_command} &&  .${Rabia_Path}" >${output_path}4.log &

sleep 5

echo "Starting client[s]"

cli_export="export RC_Role=cli RC_Index=0 RC_Proxy="34.224.78.11:9090""
nohup sshpass ssh -o "StrictHostKeyChecking no"   -i ${cert} -n -f ${client1} "${cli_export} && ${export_command} && .${Rabia_Path}" >${output_path}5.log &

cli_export="export RC_Role=cli RC_Index=1 RC_Proxy="18.207.143.224:9091""
nohup sshpass ssh -o "StrictHostKeyChecking no"   -i ${cert} -n -f ${client2} "${cli_export} && ${export_command} && .${Rabia_Path}" >${output_path}6.log &

cli_export="export RC_Role=cli RC_Index=2 RC_Proxy="54.90.145.152:9092""
nohup sshpass ssh -o "StrictHostKeyChecking no"   -i ${cert} -n -f ${client3} "${cli_export} && ${export_command} && .${Rabia_Path}" >${output_path}7.log &

cli_export="export RC_Role=cli RC_Index=3 RC_Proxy="184.72.141.58:9093""
nohup sshpass ssh -o "StrictHostKeyChecking no"   -i ${cert} -n -f ${client4} "${cli_export} && ${export_command} && .${Rabia_Path}" >${output_path}8.log &

cli_export="export RC_Role=cli RC_Index=4 RC_Proxy="54.91.91.186:9094""
nohup sshpass ssh -o "StrictHostKeyChecking no"   -i ${cert} -n -f ${client5} "${cli_export} && ${export_command} && .${Rabia_Path}" >${output_path}9.log &

echo "starting controller"

crl_export="export RC_Role=ctrl"
nohup sshpass ssh -o "StrictHostKeyChecking no"    -i ${cert} -n -f ${replica1} "${crl_export} && ${export_command} && .${Rabia_Path}" >${output_path}10.log &

sleep 80

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

Sleep 10

echo "Finish test"