#!/bin/bash

#dos2unix mark.sh Makefile
#le faire avant de lancer le script si il est marqué comme introuvable

mark=0
firstLine=$(head -n 1 note.csv)
if [[ "$firstLine" != "Nom,Prénom,Note" ]]; then
    echo "Nom,Prénom,Note" >> note.csv
fi

#Récupère le nom complet de l'élève dans le readme.txt

while IFS=" " read -r rec_column1 rec_column2 || [ -n "$rec_column1" ]
do
    [ -z "$rec_column1" ] && continue

    echo "Note de $rec_column1 $rec_column2"
    firstName="$rec_column1"
    lastName="${rec_column2/$'\r'/}"
    mark=0

done < "readme.txt"

make 
# Si la compilation a fonctionn<e", ajoute 2" points
if [ $? -eq 0 ]; then
    echo "La compilation a fonctionnée"
    ((mark+=2))
    echo +2 sur la compil
    
# Mets 0 si cela n'a pas fonctionnée
else
    echo "La compilation a échoué"
    echo "'$firstName','$lastName','$mark'" >> note.csv
    exit 1
    echo "0 sur la compil"
fi

# Initie la variable pour voir si les résultats de la factorielle en c et celle en shell ont les même résultats
sameResult=false
# Vérifie la facto entre 1 et 10
for ((i=1 ; i<=10 ; i++))
do
    result=$(./factorielle $i)
    factor=1

    # Facto faites maison
        for ((j=1 ; j<=i ; j++))
        do
            ((factor*=j))
        done
    # Compare les résultats des 2 factos, si différents, change en sameResult en faux
    if [ "$factor" -eq "$result" ]; then
        sameResult=true
        break
    fi
done  

# Si tous les résultats sont les mêmes alors on ajoute les 5 points 
if $sameResult; then
    ((mark+=5))
    echo "+5 sur la facto entre 1 et 10"
else
    echo "pas de +5 sur la facto"
fi

# Calcul si la factorielle 0 = 1
facto0=$(./factorielle "0")
facto1result=1

if [ "$facto0" -eq "$facto1result" ]; then
    ((mark+=3))
    echo "+3 sur la facto à 0"
else 
    echo "Raté, reçu '$facto0' au lieu de '1'"
    echo "pas de +3 sur la facto à 0"
fi

# Vérifie si la signature est bonne
point=false

for file in *.c
    do
    signature=$(grep "int factorielle" $file)

    if [[ "$signature" = *"int factorielle( int number )"* ]]; then
        point=true
    fi
done

if $point; then
    ((mark+=2))
    echo +2 sur la sign
else
    echo pas de +2 sur la sign
fi

#Vérifie si le programme gère un nombre inexact de paramètre
noArgument=$(./factorielle 2>&1)
moreThanOneArg=$(./factorielle 5 10 2>&1)
errorMessage="Erreur: Mauvais nombre de parametres"
if [[ "$noArgument" == "$errorMessage" && "$moreThanOneArg" == "$errorMessage" ]]; then
    ((mark+=4))
    echo "+4 sur le nombre de parametre"
else
    echo pas de +4 sur le nombre de param
fi

#Vérifie si le programme gère un nombre négatif
negativeNumber=$(./factorielle "-1")
if [[ "$negativeNumber" = "Erreur: nombre negatif" ]]; then
    ((mark+=4))
    echo +4 sur la gestion des nombres négatifs
else
    echo pas de +4 sur la gestion des nombres negatifs
fi

#Vérifie les conventions du fichier
malus=true

for file in *.c *.h
do
    columnConvention=$(grep -cE '.{81,}' $file)

    if [ "$columnConvention" -gt 0 ]; then
        echo "Il y a $columnConvention lignes qui dépassent les 80 caractères"
    else
        echo "Convention des colonnes respectée dans $file"
        malus=false
    fi
done

if $malus; then
    ((mark-=2))
    echo "-2 sur la convention des colonnes"
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
    echo "-2 sur l'indentation"
else
    echo Indentations respectées
fi

#Vérification de l'existance du fichier header.h
header="header.h"
if [[ ! -f "$header" ]]; then
    ((mark-=2))
    echo "-2 sur l'inexistance de l'header"
fi

#Vérifie si la suppression de l'éxécutable fonctionne
make clean
if [ $? -ne 0 ]; then
    ((mark-=2))
    echo "-2 sur le clean qui ne fonctionne pas"
fi

#Note finale de l'élève
echo $firstName $lastName, $mark
echo "'$firstName','$lastName','$mark'" >> note.csv
