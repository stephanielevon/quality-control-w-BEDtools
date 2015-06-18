#!/usr/bin/env perl


# Date : 13/04/15
# Author : Levon Stephanie 
# Purpose : utiliser l'outil BEDtools et la commande "coverage". Nécessite deux fichiers : le fichier .bam (reads alignés) 
# et le fichier .bed (coordonnées des capture). 

use strict;
use warnings;
use Getopt::Long;
use Statistics::R;

#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Récupérer les noms de fichiers en arguments, vérifier qu'il y a autant d'arguments que nécessaire
#---------------------------------------------------------------------------------------------------------------------------------------------------------


my $desc = "\n Deux arguments requis : --bam <in.bam> --bed <in.bed> \n\n";

my %options = (); # Toutes options données en ligne de commande sont enregistrées dans un tabelau associatif
my $nbArguments = @ARGV;

GetOptions ("bam=s"   => \$options{"bam_file"}, 
            "bed=s"  => \$options{"bed_file"})
# si help est initialisé print l'aide 
               
 or die($desc);

if ($nbArguments != 4){
	print $desc;
	exit
}
#pod2usage( # print a usage message from embedded pod documentation
#	)if (defined$options{"help"} || $nbArguments == 0);


#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Exécuter une commande bash avec l'outil BEDtools coverage, rediriger les résultats dans un fchier output portant le nom du fichier bed .coverage.tsv
#---------------------------------------------------------------------------------------------------------------------------------------------------------

my @output = split(/\./, $options{"bed_file"}); # Se sert du nom de fichier entré par l'utilisateur pour nommer le nouveau fichier
my $bedtools_res = $output[0].".coverage.tsv"; 
system (" bedtools coverage -b $options{bed_file} -abam $options{bam_file} > $bedtools_res "); # Place dans un fichier de sortie 
my $bedtools_sorted = $output[0].".coverage_sorted.tsv"; 
system("sed 's/^chr//g' $bedtools_res | sort -k 1,1n  > $bedtools_sorted"); # | awk '{print \"chr\"\$0}';


#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Générer un ou plusieurs graphiques avec R dans un fichier PDF portant le nom du fichier bed .plot.pdf
#---------------------------------------------------------------------------------------------------------------------------------------------------------

my $R = Statistics::R->new(); 
$R -> startR() ; # Ouvrir une session R 

my @output_plot = split(/\./, $bedtools_res);
$R->run(qq`pdf("$output_plot[0].plot.pdf")`); # Lancer la commande R qui va créer notre fichier .pdf trier 

my$plot_file = $R -> run (
	qq`data <- read.table("/Users/stephanie/Desktop/fichier_test/$bedtools_res", header=F)`,
	
	q`chr <- data[, 1]`,
	q`chr = factor(chr,levels(chr)[c(1, 11, 15:20, 2:10, 12:14, 21, 22)])`,

	q`depth <- data[, 4]`,
	q`ratio <- data [,7]`,

	q`hist(ratio)`,

	q`boxplot (depth~chr, las=2, ylim = c (0, 16000), col = heat.colors(22))`,
	q`title (main = "Comparaison des densités de lectures \n par régions cibles par chromosome", xlab = "Chromosome", ylab = "Densité de lectures par région ciblée")`,

	q`dev.off()`
	);

$R->stopR(); # Fermer la session R et l'interaction avec Perl

#if (-e $output_plot[0].plot.pdf){
#print "Fichiers créés : \n - $bedtools_res \n - $output_plot[0].plot.pdf \n";
#}

