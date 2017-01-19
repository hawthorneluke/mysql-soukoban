# Impletation of the [Soukoban](https://en.wikipedia.org/wiki/Sokoban) game in MySQL

---

## Install
1. Create `soukoban` database
 - `create database soukoban;`
- Create `soukoban` user with all privileges on `soukoban` database
 - `create user soukoban;`
 - `grant all privileges on soukoban.* to soukoban;`
- Execute dump.sql
 - `mysql -u root soukoban < dump.sql`
 - (add -p if root user has password)

## Play
1. Execute soukoban.sh
 - `./soukoban.sh`
- Use arrow keys to move

