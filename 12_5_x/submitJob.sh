#!/bin/bash

doSubmit=true
dt=`date '+%Y%m%d_%H%M%S'`
reTar=true #only need once

###-----     Edit for your working area
lxplusBase=$PWD/../..   #/afs/cern.ch/work/d/ddiaz/L1SampleGen/cleanBuild
scriptsDir=$PWD   #/afs/cern.ch/work/d/ddiaz/L1SampleGen/cleanBuild/L1_sampleGen/12_5_x
ntupleDir=${lxplusBase}/Tuples-el8  #/afs/cern.ch/work/d/ddiaz/L1SampleGen/cleanBuild/Tuples-el8
#sampleName="HiddenGluGluH_mH-125_Phi-30_ctau-100"
sampleName="HiddenGluGluH_mH-125_Phi-15_ctau-100_4b"
outdir="/store/group/LLPs/russelld/"${sampleName}"_TuneCP5_14TeV-pythia8/condor_FALL22_UAF/$dt/0000/"
NJobs=2
NEvents=10 
###----
# Get the first letter of the username and build proxy path
FIRST_LETTER=$(echo $USER | cut -c 1)
Proxy_path="/afs/cern.ch/user/${FIRST_LETTER}/${USER}/private/x509up"
echo "searching for proxy in $Proxy_path"

declare -A map

map["HiddenGluGluH_mH-125_Phi-30_ctau-1_4b"]="TSG-Phase2Fall22GS-00122-fragment.py"
map["HiddenGluGluH_mH-125_Phi-30_ctau-10_4b"]="H2H1H1_4b_M30_ctau10mm-fragment.py"
map["HiddenGluGluH_mH-125_Phi-30_ctau-100_4b"]="H2H1H1_4b_M30_ctau100mm-fragment.py"
map["HiddenGluGluH_mH-125_Phi-15_ctau-100_4b"]="H2H1H1_4b_M15_ctau100mm-fragment.py"
map["HiddenGluGluH_mH-125_Phi-60_ctau-100_4b"]="H2H1H1_4b_M60_ctau100mm-fragment.py"
map["HiddenGluGluH_mH-125_Phi-30_ctau-1000_4b"]="H2H1H1_4b_M30_ctau1000mm-fragment.py"
map["HiddenGluGluH_mH-125_Phi-30_ctau-1_4c"]="H2H1H1_4c_M30_ctau1mm-fragment.py"
map["HiddenGluGluH_mH-125_Phi-30_ctau-10_4c"]="H2H1H1_4c_M30_ctau10mm-fragment.py"
map["HiddenGluGluH_mH-125_Phi-30_ctau-100_4c"]="H2H1H1_4c_M30_ctau100mm-fragment.py"
map["HiddenGluGluH_mH-125_Phi-15_ctau-100_4c"]="H2H1H1_4c_M15_ctau100mm-fragment.py"
map["HiddenGluGluH_mH-125_Phi-60_ctau-100_4c"]="H2H1H1_4c_M60_ctau100mm-fragment.py"
map["HiddenGluGluH_mH-125_Phi-30_ctau-1000_4c"]="H2H1H1_4c_M30_ctau1000mm-fragment.py"


##--Create cfg files
bash DriverCmnd_GENSIM.sh --theFragment=${map[$sampleName]}
bash DriverCmnd_DIGI.sh #> /dev/null 2>&1

cp runJob.sh $lxplusBase/
#get the two CMSSW working areas
if [ ${reTar} = true ]
then
  cd $scriptsDir
  tar -czf  CMSSW_125x.tar.gz CMSSW_12_5_2_patch1
  mv CMSSW_125x.tar.gz $lxplusBase
  cd $lxplusBase
  pwd
  cd $ntupleDir
  pwd
  tar -czf  CMSSW_125x_tup.tar.gz CMSSW_12_5_2_patch1
  mv CMSSW_125x_tup.tar.gz $lxplusBase
  cd $lxplusBase
fi

cd $lxplusBase
mkdir -p "logs/$dt"
echo "logs at:  logs/$dt"

 #write base for submit file
 printf "universe = vanilla\n" > submitfile
 printf '+JobFlavour = "tomorrow"\n' > submitfile
 printf "Executable = runJob.sh\n" >> submitfile
 printf "Should_Transfer_Files = YES \n" >> submitfile
 #printf "WhenToTransferOutput = ON_EXIT\n" >> submitfile
 printf "Transfer_Input_Files = $scriptsDir/MakeGS_cfg.py, $scriptsDir/MakeDIGI_cfg.py, CMSSW_125x.tar.gz, CMSSW_125x_tup.tar.gz\n" >> submitfile

 printf "notify_user = $(whoami)@cern.ch\n" >> submitfile
 printf "x509userproxy = $Proxy_path\n" >> submitfile
 #printf 'requirements = (OpSysAndVer =?= "CentOS8")\n' >> submitfile
 printf 'MY.SingularityImage = "/cvmfs/unpacked.cern.ch/gitlab-registry.cern.ch/batch-team/containers/plusbatch/cs8-full:latest"\n' >> submitfile
 printf "MY.XRDCP_CREATE_DIR = True\n" >> submitfile
 printf "Output = logs/$dt/\$(Cluster)_\$(Process).stdout\n" >> submitfile
 printf "Error  = logs/$dt/\$(Cluster)_\$(Process).stderr\n" >> submitfile
 printf "Log    = logs/$dt/\$(Cluster)_\$(Process).log\n" >> submitfile
 printf "\n" >> submitfile
 #printf "output_destination = root://eosuser.cern.ch//eos/user/ddiaz/L1LLPSample/HiddenGluGluH_mH-125_Phi-30_ctau-100_TuneCP5_14TeV-pythia8/crab_100kDIGI_Spring22_UAF/"$dt"/"$(ClusterId)"/ \n" >>submitfile
 #printf "MY.XRDCP_CREATE_DIR = True\n" >> submitfile

 printf "Arguments = $Proxy_path ${sampleName}_\$(ProcId).root $NJobs $NEvents $outdir \n" >> submitfile
 #printf "Arguments = $Proxy_path test.root $NJobs $NEvents $outdir \n" >> submitfile
 printf "Queue ${NJobs}\n" >> submitfile
 printf "\n" >> submitfile

 if [ ${doSubmit} = true ]
 then
  xrdfs root://redirector.t2.ucsd.edu:1095/ mkdir -p $outdir
  condor_submit submitfile
 fi
