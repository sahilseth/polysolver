#!/bin/bash -l   

date

if [ $# -ne 4 ]
then
 echo "Usage: excludeLDFile dataDir filePrefix outDir"
 echo "where filePrefix is the file name without the extension"
 exit 1 
fi

#Parse arguments
excludeLDFile=$1
dataDir=$2
prefix=$3
outDir=$4

echo "excludeLDFile: $excludeLDFile"
echo "dataDir: $dataDir"
echo "prefix: $prefix"
echo "outDir: $outDir"

if [ ! -e $excludeLDFile ]
then
  echo "ERROR: Missing file $excludeLDFile"
  exit 1
fi

#Check if files exist
if [ ! -e ${dataDir}/${prefix}.map ]
then
  echo "Missing file ${dataDir}/${prefix}.map"
  exit 1
fi

if [ ! -e ${dataDir}/${prefix}.ped ]
then
  echo "Missing file ${dataDir}/${prefix}.ped"
  exit 1
fi

cp -v ${dataDir}/${prefix}.map ${outDir}

inPedFile=${dataDir}/${prefix}.ped
outPedFile=${outDir}/${prefix}.ped

if [ ! -e $outPedFile ]
then 
 #Fixing phenotypes in ped file
 cut -d " " -f 1,3,4,5,6 $inPedFile > ${outDir}/${prefix}.ped.col1to6skip2.txt
 cut -d " " -f 7- $inPedFile > ${outDir}/${prefix}.ped.col7down.txt
 sed -i 's/0 0 0 -9$/\. 0 0 0 1/' ${outDir}/${prefix}.ped.col1to6skip2.txt

 echo "Pasting"
 paste -d " " ${outDir}/${prefix}.ped.col1to6skip2.txt ${outDir}/${prefix}.ped.col7down.txt > ${outPedFile}
 rm -vf ${outDir}/${prefix}.ped.col1to6skip2.txt
 rm -vf ${outDir}/${prefix}.ped.col7down.txt
else
 echo "pedFile exists: $outPedFile"
fi

par=${prefix}.pcapar

echo "Creating parameter files"
if [ ! -e ${outDir}/${par} ]
then
  echo "Creating parameter file for smartpca"
  echo "numoutevec:      100" > ${outDir}/${par}
  echo "genotypename:    ${outDir}/${prefix}.ped" >> ${outDir}/${par}
  echo "snpname:         ${outDir}/${prefix}.map" >> ${outDir}/${par}
  echo "indivname:       ${outDir}/${prefix}.ped" >> ${outDir}/${par}
  echo "xregionname:     ${excludeLDFile}" >> ${outDir}/${par}
  echo "evecoutname:     ${outDir}/${prefix}.pcaOut.evec" >> ${outDir}/${par}
  echo "evaloutname:     ${outDir}/${prefix}.pcaOut.eval" >> ${outDir}/${par}
  echo "outlieroutname:  ${outDir}/${prefix}.pcaOut.outliers" >> ${outDir}/${par}
  echo "snpweightoutname: ${outDir}/${prefix}.pcaOut.snpweight" >> ${outDir}/${par}
  echo "deletesnpoutname: ${outDir}/${prefix}.pcaOut.deletesnp" >> ${outDir}/${par}
  echo "numthreads:      4" >> ${outDir}/${par}
  echo "altnormstyle:    NO" >> ${outDir}/${par}
else 
  echo "File exists ${outDir}/${par}"
fi

if [ ! -e ${outDir}/${prefix}.pcaOut.evec ]
then
  echo "Running PCA on ${prefix}"
  $EIGENTOOLS_DIR/smartpca -p ${outDir}/${par}
else
  echo "File exists ${outDir}/${prefix}.pcaOut.evec" 
fi

echo "Converting results for plotting" 
cat ${outDir}/${prefix}.pcaOut.evec | sed 's/ [ ]*/\t/g' | sed 's/^\t//' | tail -n +2 | sed 's/:\.//' > ${outDir}/${prefix}.pcaOut.evec.tsv

date

