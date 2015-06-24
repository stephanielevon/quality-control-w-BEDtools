#!/usr/bin/env perl # Variable d'environnement. Indique que l'interpreteur est Perl, celui-ci sera utilisé quelque soit sa localisation. 


# Date : 13/04/15
# Auteur : Levon Stephanie 
# But : utiliser l'outil BEDtools et la commande "coverage". Nécessite deux fichiers : le fichier .bam (lectures alignées) 
# et le fichier .bed (coordonnées des capture). 

use strict;
use warnings;
use Getopt::Long;
use Statistics::R;

#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Récupérer les noms de fichiers en arguments, vérifier qu'il y a autant d'arguments que nécessaire
#---------------------------------------------------------------------------------------------------------------------------------------------------------


my $desc = "\n Deux arguments requis : --bam <in.bam> --bed <in.bed> \n\n";

my %options = (); # Toutes les options données en ligne de commande sont enregistrées dans un tabelau associatif
my $nbArguments = @ARGV;

GetOptions ("bam=s"   => \$options{"bam_file"}, 
            "bed=s"  => \$options{"bed_file"})
        
 or die($desc);

if ($nbArguments != 4){
	print $desc;
	exit
}


#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Exécuter une commande bash avec l'outil BEDtools coverage, rediriger les résultats dans un fchier output portant le nom du fichier bam .coverage.tsv
#---------------------------------------------------------------------------------------------------------------------------------------------------------

my @output = split(/\./, $options{"bam_file"}); # Se sert du nom de fichier entré par l'utilisateur pour nommer le nouveau fichier qui contiendra les résultats de la commande BEDTools coverage
my $bedtools_res = $output[0].".coverage.tsv"; 
# La commande suivante prend en paramètre le fichier bed (-b) et le fichier bam (-abam)
system (" bedtools coverage -b $options{bed_file} -abam $options{bam_file} > $bedtools_res "); # Place le résultat dans un fichier de sortie qui prend le nom du fichier et ajoute en préfixe ".coverage.tsv"
my $bedtools_sorted = $output[0].".coverage_sorted.tsv"; 
system("sed 's/^chr//g' $bedtools_res | sort -k 1,1n  > $bedtools_sorted"); # Permet d'obtenir un fichier trié (optionnel)


#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Générer un ou plusieurs graphiques avec R dans un fichier PDF portant le nom du fichier bed .plot.pdf
#---------------------------------------------------------------------------------------------------------------------------------------------------------

my $R = Statistics::R->new(); 
$R -> startR() ; # Ouvrir une session R 

my @output_plot = split(/\./, $bedtools_res);
$R->run(qq`pdf("$output_plot[0].plot.pdf")`); # Lancer la commande R qui va créer notre fichier .pdf et le nommer avec le nom du fichier bam suivit de ".plot.pdf"

my$plot_file = $R -> run (
	qq`data <- read.table("/Users/stephanie/Documents/script_qc_bedtools/$bedtools_res", header=F)`, # Va chercher le fichier a son emplacement
	
	q`chr <- data[, 1]`,
	q`chr = factor(chr,levels(chr)[c(1, 11, 15:20, 2:10, 12:14, 21, 22)])`,

	q`depth <- data[, 4]`,
	q`ratio <- data [,7]`,

	q`hist(ratio)`,

	q`boxplot (depth~chr, las=2, ylim = c (0, 16000), col = heat.colors(22))`,
	q`title (main = "Comparaison du nombre de lectures \n par région de capture et par chromosome", xlab = "Chromosome", ylab = "Nombre de lectures par région ciblée")`,

	q`dev.off()`
	);

$R->stopR(); # Fermer la session R et l'interaction avec Perl



