#!/bin/bash

echo "System software: `cat /etc/redhat-release`" #Operating System on that node
export X509_USER_PROXY=$1
voms-proxy-info -all
voms-proxy-info -all -file $1
source /cvmfs/cms.cern.ch/cmsset_default.sh

echo "working area: " $PWD
ls
echo "opening MC GENSIM/DIGI CMSSW"
tar -zxf CMSSW_125x.tar.gz
cd CMSSW_12_5_2_patch1/src 
cmsenv
cd - 

echo @@@@@@@@@@  RUNNING STEP 1 @@@@@@@@@@@@@@@@@@@@@@
cmsRun MakeGS_cfg.py maxEvents=$4 > /dev/null 2>&1
echo "Do an ls to see if GENSIM rootgenerated"
ls

echo @@@@@@@@@@  RUNNING STEP 2 @@@@@@@@@@@@@@@@@@@@@@
cmsRun MakeDIGI_cfg.py maxEvents=$4 > /dev/null 2>&1

#Kill old version of CMSSW
rm -rf CMSSW_12_5_2_patch1
echo "Do an ls to see if output roots both generated"
ls

echo @@@@@@@@@@  opening ntuple CMSSW @@@@@@@@@@@@@@@@@@@@@@
export SCRAM_ARCH=el8_amd64_gcc10
tar -zxf CMSSW_125x_tup.tar.gz
mv GENSIMDIGIRAW.root CMSSW_12_5_2_patch1/src/FastPUPPI/NtupleProducer/python/
rm G*.root
echo "reached the error when accessing Tuple-el8. Do pwd to see if we are in the correct loc."
pwd
cd CMSSW_12_5_2_patch1/src 
cmsenv
cd FastPUPPI/NtupleProducer/python/
echo @@@@@@@@@@ do an ls and pwd @@@@@@@@@@@@@@@@@@@@@@
ls
pwd

echo @@@@@@@@@@  RUNNING STEP 3 \(ntuple\) @@@@@@@@@@@@@@@@@@@@@@
cmsRun runL1PFNTupler_Full125x.py outputFile=$2

rm G*.root
rm Isolation*.txt
echo @@@@@@@@@@  ls and check that runL1PFNTupler ran @@@@@@@@@@@@@@@@@@@@@@
rm GENSIMDIGIRAW.root
ls


echo @@@@@@@@@@  COPYING OUTPUT @@@@@@@@@@@@@@@@@@@@@@
echo "copying to: " $5
xrdcp HiddenGluGluH*.root root://redirector.t2.ucsd.edu:1095/$5 
rm HiddenGluGluH*.root
ls
