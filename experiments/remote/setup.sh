# Copy rabia to all machines

reset_directory="rm -r /home/pasindu/rabia; mkdir /home/pasindu/rabia"
kill_insstances="pkill rabia ; pkill rabia; pkill rabia"

replica1=pasindu@dedis-140.icsil1.epfl.ch
replica1_cert="/home/pasindu/Pictures/pasindu_rsa"
replica2=pasindu@dedis-141.icsil1.epfl.ch
replica2_cert="/home/pasindu/Pictures/pasindu_rsa"
replica3=pasindu@dedis-142.icsil1.epfl.ch
replica3_cert="/home/pasindu/Pictures/pasindu_rsa"

client1=pasindu@dedis-145.icsil1.epfl.ch
client1_cert="/home/pasindu/Pictures/pasindu_rsa"
client2=pasindu@dedis-146.icsil1.epfl.ch
client2_cert="/home/pasindu/Pictures/pasindu_rsa"
client3=pasindu@dedis-147.icsil1.epfl.ch
client3_cert="/home/pasindu/Pictures/pasindu_rsa"

replica6=pasindu@dedis-143.icsil1.epfl.ch
replica6_cert="/home/pasindu/Pictures/pasindu_rsa"

local_rabia_path="rabia"
replica_home_path="/home/pasindu/rabia/"

echo "Replica 1"
sshpass ssh ${replica1} -i ${replica1_cert} ${reset_directory}
sshpass ssh ${replica1} -i ${replica1_cert} ${kill_insstances}
scp -i ${replica1_cert} ${local_rabia_path} ${replica1}:${replica_home_path}

echo "Replica 2"
sshpass ssh ${replica2} -i ${replica2_cert} ${reset_directory}
sshpass ssh ${replica2} -i ${replica2_cert} ${kill_insstances}
scp -i ${replica2_cert} ${local_rabia_path} ${replica2}:${replica_home_path}

echo "Replica 3"
sshpass ssh ${replica3} -i ${replica3_cert} ${reset_directory}
sshpass ssh ${replica3} -i ${replica3_cert} ${kill_insstances}
scp -i ${replica3_cert} ${local_rabia_path} ${replica3}:${replica_home_path}

echo "Replica 6"
sshpass ssh ${replica6} -i ${replica6_cert} ${reset_directory}
sshpass ssh ${replica6} -i ${replica6_cert} ${kill_insstances}
scp -i ${replica6_cert} ${local_rabia_path} ${replica6}:${replica_home_path}

echo "Client 1"
sshpass ssh ${client1} -i ${client1_cert} ${reset_directory}
sshpass ssh ${client1} -i ${client1_cert} ${kill_insstances}
scp -i ${client1_cert} ${local_rabia_path} ${client1}:${replica_home_path}

echo "Client 2"
sshpass ssh ${client2} -i ${client2_cert} ${reset_directory}
sshpass ssh ${client2} -i ${client2_cert} ${kill_insstances}
scp -i ${client2_cert} ${local_rabia_path} ${client2}:${replica_home_path}

echo "Client 3"
sshpass ssh ${client3} -i ${client3_cert} ${reset_directory}
sshpass ssh ${client3} -i ${client3_cert} ${kill_insstances}
scp -i ${client3_cert} ${local_rabia_path} ${client3}:${replica_home_path}

echo "setup complete"
