# centos7_meza

Step 1. Log into VM as <b>root</b> and install git, clone repo, and run root_init.sh<br>
<code>yum install -y git</code><br>
<code>git clone https://github.com/AudioSlav3/centos7_meza.git</code><br>
<code>cd centos7_meza</code><br>
<code>bash root_init.sh</code><br>

Step 2. Change to user and run user_init.sh<br>
<code>sudo su - {user}</code><br>
<code>git clone https://github.com/AudioSlav3/centos7_meza.git</code><br>
<code>cd centos7_meza</code><br>
<code>bash user_init.sh</code><br>

Step 3. Run meza_init.sh<br>
<code>bash meza_init.sh</code><br>