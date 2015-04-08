# Date : 01/04/15
# Auteur : Levon Stephanie 
# But : utiliser l'outil SAMtools "view". Nécessite deux fichiers : le fichier .bam (reads alignés) et le fichier .bed (coordonnées des captures d'exons). Pour chaque ligne du fichier .bed, executer la commande view et wc -l pour compter le nombre de reads associé à chaque gène. 

#$ARGV[0] : fichier .bam
#$ARGV[1] : fichier .bed

#!/usr/bin/perl
use strict;
use warnings;
#use Statistics::R; lancer un script R

# Fichier .bed
# Si la ligne du fichier bed commence par "chr"
# Construire une expression : Placer en arguments la colonne 0 puis ":" puis la colonne 1 puis "-" puis la colonne 2
# Lancer la commande samtools view | wc -l
# Récupérer les résultats dans un tableau 
# Afficher le nombre moyen de read / position, sous forme de boxplot (mediane, quartile, min, max)? Soit un seul boxplot pr l'ensemble du fichier de read
my$nbArguments=$#ARGV;
my$bam_file="Marked_NDT-150_2.bam";	#$ARGV[0];
my$bed_file=$ARGV[0];
#print $nbArguments;
my$error = "Deux fichiers sont requis en arguments.\n"; 
if ($nbArguments != "1") {
	print "$error"
	} 

unless (open(FIC_CAPTURE, $bed_file)){  # Ouvrir le fichier .bed 
    print "Impossible d'ouvrir le fichier $bed_file!\n"; # Afficher un message d'erreur lorsque le fichier ne peut pas etre ouvert
    exit; 
}
my@bed_file=<FIC_CAPTURE>; # Enregistrer le fichier dans un tableau appelé bed_file
    close FIC_CAPTURE; # Fermer le descripteur de fichier

foreach my$line(@bed_file){ # Pour chaque ligne du tableau bed_file 
    if($line=~/^chr/){ # Si la ligne commence par les caractères "chr"
    #print $line;
    my @bed = split("\t",$line); # Chaque élèment séparé par une tabulation se retrouve dans une colonne du tableau associatif        
    my$view=($bed[0].":".$bed[1]."-".$bed[2]); #chr1:210111511-210111704
    #print $view; 
   
    my$count=`samtools view $bam_file $view | wc -l`; # Marked_NDT-150_2.bam chr1:210111511-210111704
    print $count; 

    }
    #print "@bed_file\n";
}

        


#my$file=`ls -l`;

