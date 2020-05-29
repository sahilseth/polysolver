#!/usr/bin/perl

use Math::BaseCalc;

#usage: /cga/wu/sachet/hla/hla_caller/check_bam_flag_pairs.pl temp.txt 0 1
# Note: run the shell_check_bam_flag_pairs which contains this script first

$inFile = $ARGV[0]; # file containing the bam file flag (ex. a sam file)
$header = $ARGV[1]; # 0 or 1
$flagCol = $ARGV[2]; # 1-base
$outDir = $ARGV[3];
$outFile = $outDir."/"."check.status.out.txt";

open OUTFILE, ">$outFile" || die "Cannot open outFile=$outFile\n";

$calc = new Math::BaseCalc(digits => [0,1]); #Binary
$bin_string = $calc->to_base('7'); # Convert 465 to binary
$string = $calc->from_base('011');
#print "$bin_string\t$string\n";

open INFILE, $inFile || die "Cannot open infile=$inFile\n";


if($header == 1){
        $header = <INFILE>;
        chomp($header);
}
$paired = 1;
while($line = <INFILE>){
        chomp($line);
        @f = split(/\t/,$line);
        $flag = $f[$flagCol - 1];
        $bin_string = $calc->to_base($flag);
        #print "flag=$flag\t$bin_string\n";
        @flags = split(//,$bin_string);
        #print "flags1 = @flags\n";
        #for($i = 0; $i <= $#flags; $i++){
        #       print "i=$i\t$flags[$i]\n";
        #}
        if($flags[$#flags]==0){
                $paired = 0;
                break;
        }
}

print OUTFILE "$paired\n";

close INFILE;
close OUTFILE;


