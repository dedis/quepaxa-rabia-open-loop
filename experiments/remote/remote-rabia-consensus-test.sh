arrivalRate=$1

Rabia_Path="/rabia/rabia"
Controller="10.156.33.143:8070"
RCFolder="/home/pasindu/rabia"
NServers=3
NFaulty=1
NClients=3
ClientBatchSize=50
ProxyBatchSize=50
ClientTimeout=60 # test duration
ProxyBatchTimeout=5
RC_Peers_N="10.156.33.140:10090,10.156.33.141:10091,10.156.33.142:10092"

output_path="logs/"
remote_log_path="/home/pasindu/rabia/"

replica1=pasindu@dedis-140.icsil1.epfl.ch
replica1_cert="/home/pasindu/Pictures/pasindu_rsa"
replica2=pasindu@dedis-141.icsil1.epfl.ch
replica2_cert="/home/pasindu/Pictures/pasindu_rsa"
replica3=pasindu@dedis-142.icsil1.epfl.ch
replica3_cert="/home/pasindu/Pictures/pasindu_rsa"
#replica4=pasindu@dedis-143.icsil1.epfl.ch
#replica4_cert="/home/pasindu/Pictures/pasindu_rsa"
#replica5=pasindu@dedis-144.icsil1.epfl.ch
#replica5_cert="/home/pasindu/Pictures/pasindu_rsa"

client1=pasindu@dedis-145.icsil1.epfl.ch
client1_cert="/home/pasindu/Pictures/pasindu_rsa"
client2=pasindu@dedis-146.icsil1.epfl.ch
client2_cert="/home/pasindu/Pictures/pasindu_rsa"
client3=pasindu@dedis-147.icsil1.epfl.ch
client3_cert="/home/pasindu/Pictures/pasindu_rsa"
#client4=pasindu@dedis-148.icsil1.epfl.ch
#client4_cert="/home/pasindu/Pictures/pasindu_rsa"
#client5=pasindu@dedis-149.icsil1.epfl.ch
#client5_cert="/home/pasindu/Pictures/pasindu_rsa"

replica6=pasindu@dedis-143.icsil1.epfl.ch
replica6_cert="/home/pasindu/Pictures/pasindu_rsa"

rm ${output_path}0.log
rm ${output_path}1.log
rm ${output_path}2.log
rm ${output_path}3.log
rm ${output_path}4.log
rm ${output_path}5.txt
rm ${output_path}6.log

echo "Removed old log files"

kill_command="pkill rabia ; pkill rabia; pkill rabia"
export_command="export LogFilePath=${remote_log_path} RC_Ctrl=${Controller} RC_Folder=${RCFolder} RC_LLevel="warn" Rabia_ClosedLoop=false Rabia_NServers=${NServers} Rabia_NFaulty=${NFaulty} Rabia_NClients=${NClients} Rabia_NConcurrency=1 Rabia_ClientBatchSize=${ClientBatchSize} Rabia_ClientTimeout=${ClientTimeout} Rabia_ClientThinkTime=0 Rabia_ClientNRequests=0 Rabia_ClientArrivalRate=${arrivalRate} Rabia_ProxyBatchSize=${ProxyBatchSize} Rabia_ProxyBatchTimeout=${ProxyBatchTimeout} Rabia_NetworkBatchSize=0 Rabia_NetworkBatchTimeout=0 RC_Peers=${RC_Peers_N} Rabia_StorageMode=2"

sshpass ssh -i ${replica1_cert} ${replica1} "${kill_command}"
sshpass ssh -i ${replica2_cert} ${replica2} "${kill_command}"
sshpass ssh -i ${replica3_cert} ${replica3} "${kill_command}"
sshpass ssh -i ${replica6_cert} ${replica6} "${kill_command}"

sshpass ssh -i ${client1_cert} ${client1} "${kill_command}"
sshpass ssh -i ${client2_cert} ${client2} "${kill_command}"
sshpass ssh -i ${client3_cert} ${client3} "${kill_command}"

echo "killed previous running instances"

sleep 5

echo "starting replicas"

svr_export="export RC_Role=svr RC_Index=0 RC_SvrIp="10.156.33.140" RC_PPort="9090" RC_NPort="10090""
nohup sshpass ssh -i ${replica1_cert} -n -f ${replica1} "${svr_export} && ${export_command} && .${Rabia_Path}" >${output_path}0.log &

svr_export="export RC_Role=svr RC_Index=1 RC_SvrIp="10.156.33.141" RC_PPort="9091" RC_NPort="10091""
nohup sshpass ssh -i ${replica2_cert} -n -f ${replica2} "${svr_export} && ${export_command} &&  .${Rabia_Path}" >${output_path}1.log &

svr_export="export RC_Role=svr RC_Index=2 RC_SvrIp="10.156.33.142" RC_PPort="9092" RC_NPort="10092""
nohup sshpass ssh -i ${replica3_cert} -n -f ${replica3} "${svr_export} && ${export_command} &&  .${Rabia_Path}" >${output_path}2.log &

echo "Started servers"

echo "Starting client[s]"

cli_export="export RC_Role=cli RC_Index=0 RC_Proxy="10.156.33.140:9090""
nohup sshpass ssh -i ${client1_cert} -n -f ${client1} "${cli_export} && ${export_command} && .${Rabia_Path}" >${output_path}3.log &

cli_export="export RC_Role=cli RC_Index=1 RC_Proxy="10.156.33.141:9091""
nohup sshpass ssh -i ${client2_cert} -n -f ${client2} "${cli_export} && ${export_command} && .${Rabia_Path}" >${output_path}4.log &

cli_export="export RC_Role=cli RC_Index=2 RC_Proxy="10.156.33.142:9092""
nohup sshpass ssh -i ${client3_cert} -n -f ${client3} "${cli_export} && ${export_command} && .${Rabia_Path}" >${output_path}5.log &

echo "started clients"

echo "starting controller"

crl_export="export RC_Role=ctrl"
nohup sshpass ssh -i ${replica6_cert} -n -f ${replica6} "${crl_export} && ${export_command} && .${Rabia_Path}" >${output_path}6.log &

sleep 80

echo "Completed Client[s]"

sleep 20

scp -i ${client1_cert} ${client1}:${remote_log_path}0.txt ${output_path}5.txt
scp -i ${client2_cert} ${client2}:${remote_log_path}1.txt ${output_path}6.txt
scp -i ${client3_cert} ${client3}:${remote_log_path}2.txt ${output_path}7.txt

dst_directory="/home/pasindu/Desktop/Test/Rabia/${arrivalRate}/"
mkdir -p "${dst_directory}"
cp -r ${output_path} "${dst_directory}"

sshpass ssh -i ${replica1_cert} ${replica1} "pkill rabia; pkill rabia; pkill rabia "
sshpass ssh -i ${replica2_cert} ${replica2} "pkill rabia; pkill rabia; pkill rabia "
sshpass ssh -i ${replica3_cert} ${replica3} "pkill rabia; pkill rabia; pkill rabia "
sshpass ssh -i ${replica6_cert} ${replica6} "pkill rabia; pkill rabia; pkill rabia "

sshpass ssh -i ${client1_cert} ${client1} "pkill rabia; pkill rabia; pkill rabia"
sshpass ssh -i ${client2_cert} ${client2} "pkill rabia; pkill rabia; pkill rabia"
sshpass ssh -i ${client3_cert} ${client3} "pkill rabia; pkill rabia; pkill rabia"

echo "killed  instances"

echo "Finish test"
