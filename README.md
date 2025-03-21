# Set up Working area
It is intended to run this code alongside the ntupler that comes from a different repository

Eventually, your working area should have this code as well as the ntupler that we wil store under the directory Tuples-el8.

This will be the base of our working area.
```
ls .
L1_sampleGen  Tuples-el8
```
Let's get the Tuples-el8 directory ready.

# Set up Ntuple producer
```
export SCRAM_ARCH=el8_amd64_gcc10
mkdir Tuples-el8; cd Tuples-el8
cmsrel CMSSW_12_5_2_patch1
cd CMSSW_12_5_2_patch1/src
cmsenv

git cms-checkout-topic -u p2l1pfp:L1PF_12_5_X
git cms-addpkg DataFormats/L1TParticleFlow
git cms-addpkg DataFormats/L1TCorrelator
git cms-addpkg L1Trigger/Phase2L1ParticleFlow
git cms-addpkg L1Trigger/TrackTrigger
git cms-addpkg SimTracker/TrackTriggerAssociation
git cms-addpkg L1Trigger/Phase2L1ParticleFlow

git clone https://github.com/Brainz22/FastPUPPI.git -b 12_5_X

scram b -j8
```
Now, let's return to the base of our working area we can do 
```
git clone git@github.com:ddiaz006/L1_sampleGen.git
```

# Set up MC generation
First source your CMSSW environment so you can run the Driver commands in the submitJobs.sh.
```
cd L1_sampleGen/12_5_x
bash setup.sh
cd CMSSW_12_5_2_patch1/src/; cmsenv; cd -;
```
Mostly, one needs to set some options in submitJobs.sh before they can begin running MC generation.

Most important: Inside `submitJobs.sh` is, point to proper directories in the code segment below.

```
doSubmit=false #If you are just testing this will prevent actual condor submission
dt=`date '+%Y%m%d_%H%M%S'`
reTar=false #Only need true for first run or if you made any code edits

###-----     Edit for your working area
lxplusBase=/afs/cern.ch/work/d/ddiaz/L1SampleGen/cleanBuild
scriptsDir=/afs/cern.ch/work/d/ddiaz/L1SampleGen/cleanBuild/L1_sampleGen/12_5_x
ntupleDir=/afs/cern.ch/work/d/ddiaz/L1SampleGen/cleanBuild/Tuples-el8
sampleName="HiddenGluGluH_mH-125_Phi-30_ctau-100"
outdir="/store/user/ddiaz/L1LLPSample/"${sampleName}"_TuneCP5_14TeV-pythia8/condor_FALL22_UAF/$dt/0000/"
NJobs=10
NEvents=10 
###----
```

# Submit Jobs

* We need to copy the proper `...-fragment.py` files into the CMSSW.
  -  Inside `L1_sampleGen/12_5_x`, do `cp genConfigs/*.py CMSSW_12_5_2_patch1/src/Configuration/GenProduction/python/`
 
* Now, we can run `bash submitJobs.sh`.

* If the above commands raises the error: `Submitting job(s)ERROR: unable to read proxy file`, we need to direct it to the proxy file produced from authentication of Voms-Certificate.
  -  `SubmitJobs.sh` has a line like `Proxy_path="/afs/cern.ch/user/${FIRST_LETTER}/${USER}/private/x509up"`.
  -  After authenticating your Voms Certificate, a file will be created, e.g. `/tmp/x509up_u151471`. We need to copy this file as:
  ```
  cp /tmp/x509up_u151471 ~/private/x509up
  ```
  This will match the file and path in the previous bullet point and `bash submitJobs.sh` should work.
  
# Utilities
## Get Latest version of the fragment code
```
rm -f request_fragment_check.py
wget -q https://raw.githubusercontent.com/cms-sw/genproductions/master/bin/utils/request_fragment_check.py
chmod +x request_fragment_check.py
```
