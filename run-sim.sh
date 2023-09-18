#!/usr/bin/env zsh
# A wrapper to quickly run the GATE simulation
simnum=$(date +%m%d%Y_%H%M)
logfname="sim_$simnum.log"
echo "Monte-Carlo simulation $simnum" > $logfname
outdir="/home/fanghan/Work/SPEBT/monte-carlo/data/$simnum"
mkdir -p $outdir
for i in {1..10}; do
    runnum=$(date +%m%d%Y_%H%M%S)
    printf "Simlulating run %s\n" $runnum
    echo "Run number $runnum" >> $logfname
    cd macro
    /usr/bin/time -a -o ../$logfname -f "Time: %e s, Max Memory: %M KB" Gate SPEBT.mac &>/dev/null
    # /usr/bin/time -a -o ../$logfname -f "Time: %e s, Memory: %K KB" ls &>/dev/null
    cd ..
    fname="$outdir/mc$runnum.root"
    # sleep 1
    printf "Merging output files to %s\n" $fname
    printf "output file: %s\n" $fname >> $logfname
    hadd $fname data/SPEBT.Singles_xlayer*.root &> /dev/null
    rm data/SPEBT.Singles_xlayer*.root
done
mv $logfname $outdir/
cp macro/source.mac $outdir/$simnum_source.mac
# cd macro
# Gate SPEBT.mac
# cd ..
# hadd /home/fanghan/Work/SPEBT/monte-carlo/$(date +%M%H%S).root data/SPEBT.Singles_xlayer*.root
