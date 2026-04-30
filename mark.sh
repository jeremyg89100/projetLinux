mark=0

make 
# Si la compilation a fonctionnée, ajoute 2 points
if [ $? -eq 0 ]; then
    echo "La compilation a fonctionnée"
    ((mark+=2))
    echo "$mark"
    
# Mets 0 si cela n'a pas fonctionnée
else
    echo "La compilation a échoué"
    cat readme.txt >> mark.csv
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

# Si tous les résultats sont les même alors on ajoute les 5 points
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

noArgument=$(./factorielle)
if [[ "$noArgument" = "Erreur: Mauvais nombre de parametres" ]]; then
    ((mark+=4))
    echo $mark
fi

negativeNumber=$(./factorielle "-1")
if [[ "$negativeNumber" = "Erreur: nombre negatif" ]]; then
    ((mark+=4))
    echo $mark
fi

header="header.h"
if [[ ! -f "$header" ]]; then
    ((mark-=2))
    echo $mark
fi

make clean 
if [ $? -ne 0 ]; then
    ((mark-=2))
    echo $mark
fi