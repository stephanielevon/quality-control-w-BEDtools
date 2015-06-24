# script_qc

Ce script a pour but de réaliser un contrôle qualité de lectures issues de séquençage d'ADN grâce à l'outil BEDTools. Au sein de la plateforme, la plupart des analyses de séquençage d'ADN sont des captures. 
Deux fichiers d'entrée sont nécessaires : <\br>
	- un fichier BAM contenant les lectures alignées sur le génome de référence <\br>
	- un fichier BED contenant les coordonnées de capture. 

Utilisation : perl script_qc.pl --bam <\fichier.bam> --bed <\fichier.bed> 


La commande BEDTools coverage génére un fichier au format tsv qui s'intitule : nom_fichier_bam.coverage.tsv. 
Celui-ci contient 6 colonnes : le numéro du chromosome, la position de début et de fin de la région d'intérêt, le nombre de lectures qui s'y alignent, la taille de la région d'intérêt, la taille de la région d'intérêt couverte par au moins une lecture et le ratio de couverture, c'est-à-dire la proportion de la région qui est couverte par au moins une lecture. 

Le module Statistics::R prend ensuite les colonnes de ratio de couverture et du nombre de lectures qui s'alignent par région pour générer deux graphiques, un histogramme et un graphiques de boîtes à moustache. Le fichier créér a pour nom : nom_fichier_bam.plot.pdf.
