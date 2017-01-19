map="map1"

show() {
  mysql -u soukoban soukoban -e "call draw(\"${map}\");"
}

move () {
  mysql -u soukoban soukoban -e "call move(\"${map}\",$1,$2);"
}

clear
show

while true
do
  read -r -sn1 t
  clear
  case $t in
    A) move 0 -1 ;;
    B) move 0 1 ;;
    C) move 1 0 ;;
    D) move -1 0 ;;
    *) show ;;
  esac
done

