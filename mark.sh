#!/bin/bash

mark=0

#Récupère le nom complet de l'élève dans le readme.txt
while IFS=" " read -r rec_column1 rec_column2
do
    echo "Note de $rec_column1 $rec_column2"
    firstName="$rec_column1"
    lastName="${rec_column2/$'\r'/}"
done < "readme.txt"

make 
# Si la compilation a fonctionn<e", ajoute 2" points
if [ $? -eq 0 ]; then
    echo "La compilation a fonctionnée"
    ((mark+=2))
    echo "$mark"
    
# Mets 0 si cela n'a pas fonctionnée
else
    echo "La compilation a échoué"
    echo "'$firstName','$lastName','$mark'" >> mark.csv
    echo " $mark" >> mark.csv
    exit 1
fi

# Initie la variable pour voir si les résultats de la factorielle en c et celle en shell ont les même résultats
sameResult=true
# Vérifie la facto entre 0 et 10
for ((i=0 ; i<=10 ; i++))
do
    result=$(./factorielle $i)
    factor=1

    # Facto faites maison
        for ((j=1 ; j<=i ; j++))
        do
            ((factor*=j))
        done
    # Compare les résultats des 2 factos, si différents, change en sameResult en faux
    if [ "$factor" -ne "$result" ]; then
        sameResult=false
        break
    fi
done  

# Si tous les résultats sont les mêmes alors on ajoute les 5 points
if [ "$sameResult" = true ]; then
    ((mark+=5))
    echo "$mark"
fi

# Calcul si la factorielle 0 = 1
facto0=$(./factorielle "0")
facto1result=1

if [ "$facto0" -eq "$facto1result" ]; then
    ((mark+=3))
    echo "$mark"
else 
    echo "Raté, reçu '$facto0' au lieu de '1'"
fi

# Vérifie si la signature est bonne
signature=$(grep "int factorielle" main.c)

if [[ "$signature" = *"int factorielle( int number )"* ]]; then
    ((mark+=2))
    echo $mark
fi

#Vérifie si le programme gère un nombre inexact de paramètre
noArgument=$(./factorielle)
if [[ "$noArgument" = "Erreur: Mauvais nombre de parametres" ]]; then
    ((mark+=4))
    echo $mark
fi

#Vérifie si le programme gère un nombre négatif
negativeNumber=$(./factorielle "-1")
if [[ "$negativeNumber" = "Erreur: nombre negatif" ]]; then
    ((mark+=4))
    echo $mark
fi

#Vérifie les conventions du fichier
columnConvention=$(grep -cE '.{81,}' main.c)
echo $columnConvention

if [ "$columnConvention" -gt 0 ]; then
    ((mark-=2))
    echo "Il y a $columnConvention lignes qui dépassent les 80 caractères"
else
    echo "Convention des colonnes respectée"
fi

malus=false

#Vérifie l'indentation du code de tous les fichiers c et h
for file in *.c *.h
do
    indentNiveau=0
    indentation=2
    ligneNum=0
    while IFS= read -r line
    do
        ((ligneNum++))

        line="${line//$'\r'/}"

        if [[ -z "${line// }" ]]; then
            continue
        fi

        space=$(expr "$line" : ' *')

        fermeture=0
        if [[ "$line" =~ ^[[:space:]]*"}" ]]; then
            fermeture=1
        fi

        verification=$(( (indentNiveau - fermeture) * indentation ))

        if [[ "$space" -ne "$verification" ]]; then
            echo $space et $verification
            echo "Ligne $ligneNum : Erreur d'indentation dans le fichier $file"
            malus=true
        fi

        opened=$(echo "$line" | grep -o "{" | wc -l)
        closed=$(echo "$line" | grep -o "}" | wc -l)
        
        indentNiveau=$(( indentNiveau + opened - closed ))
    done < $file
done

#Vérifie si il y a eu une erreur d'indentation
if $malus; then
    ((mark-=2))
fi

#Vérification de l'existance du fichier header.h
header="header.h"
if [[ ! -f "$header" ]]; then
    ((mark-=2))
    echo $mark
fi

#Vérifie si la suppresion de l'éxécutable fonctionne
make clean
if [ $? -ne 0 ]; then
    ((mark-=2))
    echo $mark
fi

#Note finale de l'élève
echo $mark
echo "'$firstName','$lastName','$mark'" >> mark.csv
