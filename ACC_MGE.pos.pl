#!usr/bin/perl -w
use strict;
use Getopt::Long;
my %opt = ();
GetOptions(\%opt,"anno_isfinder:s","anno_integrall:s","anno_plasmid:s","anno_refgenome:s","anno_vf:s");
(@ARGV==2)||die "Name: $0
Description: script to locate the arragement of ARG and MGE on the ARG carrying contig
Contact: hanpeng\@novogene.com
Usage: perl $0 <flle.gff> <arg.anno> [--options] > ACC_MGE.arrangement.xls
Parameters:
    flle.gff		gene-predict gff file
    arg.anno		arg's gene annofile
    --anno_isfinder     isfinder's contig annofile
    --anno_integrall    integrall's contig annofile
    --anno_plasmid      plasmid's contig annofile

Example: perl $0 <flle.gff> <arg.anno> --anno_isfinder isfinder.anno --anno_integrall integrall.anno --anno_plasmid plasmid.anno > ACC_MGE.arrangement.xls\n";

my ($gff,$arg_anno)=@ARGV;
my %ACC;
open IN,$gff||die$!;
while (<IN>){
    chomp;
    my @tmp=split /\t/;
    my $gene=$tmp[2];
    $ACC{$gene}=[@tmp[0,3..5]];
#    my $gene=(split/\s/,$tmp[-1])[0];
#    $ACC{$gene}=[@tmp[0,3,4,6]];
}
close IN;

my %ardbs;
open IN,$arg_anno||die$!;
#<IN>;
while (<IN>){
    chomp;
    my @tmp=split /\t/;
    $tmp[0]=~s/\_1$//;
    my $contig=${$ACC{$tmp[0]}}[0];
    my $info=join ("\t",$tmp[0],@{$ACC{$tmp[0]}}[1,2,3],$tmp[1]);
    print $contig,"\t",$info,"\n";
    push @{$ardbs{$contig}},$info;
}
close IN;

my (%inter,%is,%plasmids);
if($opt{anno_integrall}){
    open IN,$opt{anno_integrall} || die $!;
    while (<IN>){
        chomp;
        my @tmp=split /\t/;
        my $info=join ("\t",@tmp[6,7,9,4]);
        $inter{$tmp[0]}=$info;
    }
}

if($opt{anno_isfinder}){
    open IN,$opt{anno_isfinder} || die $!;
    while(<IN>){
        chomp;
        my @tmp=split /\t/;
        my $info=join ("\t",@tmp[4,6,7,9]);
        $is{$tmp[0]}=$info;
    }
    close IN;
}

if($opt{anno_plasmid}){
    open IN,$opt{anno_plasmid}||die$!;
    while (<IN>){
        chomp;
        my @tmp=split /\t/;
        my $info=join ("\t",@tmp[4,6,7,9]);
        $plasmids{$tmp[0]}=$info;
    }
    close IN;
}

print "scaftig\tardbinfo\t\t\t\t";
$opt{anno_plasmid} && print "plasmid_info\t\t\t\t";
$opt{anno_integrall} && print "Integral_info\t\t\t\t";
$opt{anno_isfinder} && print "is_info\t\t\t\t";
print "\n";
print "scaftig\tStart\tEnd\tstrand\tResistance_Type\t";
$opt{anno_plasmid} && print "plasmid_subjectid\tstart\tend\tstrand\t";
$opt{anno_integrall} && print "Integrall_ID\tstart\tend\tstrand\t";
$opt{anno_isfinder} && print "IS_ID\tstart\tend\tstrand\t";
print "\n";
foreach my $contig (keys %ardbs){
    foreach my $ardb (@{$ardbs{$contig}}){
    print  "$contig\t$ardb\t";
        if (exists $plasmids{$contig}){
            print "$plasmids{$contig}\t";
        }
        if (exists $inter{$contig}){
            print "$inter{$contig}\t";
        }

        if (exists $is{$contig}){
            print "$is{$contig}\t";
        }
    }
    print "\n";
}

