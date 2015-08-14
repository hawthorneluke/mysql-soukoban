delimiter $$
create procedure `get_x`(in ch char(1), out x int)
begin
set @sql = 'select id into @id from ?map? where ?col? like binary "?ch?"';
set @sql = replace(@sql, '?map?', @map);
set @sql = replace(@sql, '?ch?', ch);
call get_col_id(@sql, x, "col");
end$$
delimiter ;

delimiter $$
create procedure `get_y`(in ch char(1), out y int)
begin
set @sql = 'select id into @id from ?map? where ?col? like binary "?ch?"';
set @sql = replace(@sql, '?map?', @map);
set @sql = replace(@sql, '?ch?', ch);
call get_col_id(@sql, y, "id");
end$$
delimiter ;

delimiter $$
create procedure `draw`(in map varchar(100))
begin
declare win bool;
set @map = map;
set win = 0;
set @sql = 'select * from ?map?';
set @sql = replace(@sql, '?map?', map);
prepare stmt from @sql;
execute stmt;
call win_check(win);
if (win = 1) then
select 'YOU WIN!' as "";
end if;
end$$
delimiter ;

delimiter $$
create procedure `move_thing`(in x int, in y int, in dx int, in dy int, in bch char(1), in ach char(1), in go_deeper bool)
begin
declare newx int;
declare newy int;
declare ch char(1);

set newx = x + dx;
set newy = y + dy;
if (newx < 1 or newx > (select width from sizes where name = @map limit 1) or newy < 1 or newy > (select height from sizes where name = @map limit 1)) then
call raise_error_out_of_bounds;
end if;

call chk(newx, newy, ch);

if (ch = "#") then
 call raise_error_wall;
elseif (ch like binary "o") then
 if (go_deeper = 1) then
  call move_thing(newx, newy, dx, dy, "o", " ", 0);
 else
  call raise_error_block;
 end if;
elseif (ch like binary "O") then
 if (go_deeper = 1) then
  call move_thing(newx, newy, dx, dy, "o", ".", 0);
  set bch = "P";
 else
  call raise_error_block;
 end if;
elseif (ch = ".") then
 if (bch like binary "o") then
  set bch = "O";
 elseif (bch like binary "p") then
  set bch = "P";
 elseif (bch like binary "P") then
  set bch = "P";
  set ach = ".";
 end if;
elseif (ch = " " or ch = "") then
 if (bch like binary "P") then
  set ach = ".";
  set bch = "p";
 end if;
end if;

call upd(x, y, ach);

call upd(newx, newy, bch);
end$$
delimiter ;

delimiter $$
create procedure `move_player`(in dx int, in dy int)
begin
declare x int;
declare y int;
declare bch char(1);

set bch = "p";
call get_x(bch, x);
call get_y(bch, y);
if (x is null or y is null) then
set bch = "P";
call get_x(bch, x);
call get_y(bch, y);
if (x is null or y is null) then
call raise_error_no_player;
end if;
end if;

set max_sp_recursion_depth = 1;
call move_thing(x, y, dx, dy, bch, " ", 1);
end$$
delimiter ;


delimiter $$
create procedure `move`(in map varchar(100), in dx int, in dy int)
begin
DECLARE `_rollback` BOOL DEFAULT 0;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `_rollback` = 1;
START TRANSACTION;
set @map = map;
call move_player(dx, dy);
    
IF `_rollback` THEN
ROLLBACK;
ELSE
COMMIT;
END IF;

call draw(map);
end$$
delimiter ;

delimiter $$
create procedure `win_check`(out win bool)
begin
declare id int;
set win = 1;
set @sql = 'select id into @id from ?map? where ?col? = "." or ?col? like binary "P"';
set @sql = replace(@sql, '?map?', @map);
call get_col_id(@sql, id, "col");
if (id is not null) then
set win = 0;
end if;
end$$
delimiter ;

delimiter $$
create procedure `get_col_id`(in sql_str varchar(1000), out rtn int, in type varchar(100))
begin
declare pos int;
declare total int;
declare total_cols int;
declare col_ch char(1);
declare col_id int;

declare col_cur cursor for select col, id from cols;
set rtn = null;
set pos = 0;

select width into total from sizes where name = @map;
open col_cur;

while (total > pos) do
 fetch col_cur into col_ch, col_id;
 set @id = null;
 set @sql = replace(sql_str, '?col?', col_ch);
 prepare stmt from @sql;
 execute stmt;

 if (@id is not null) then
  if (type = "col") then
   set rtn = col_id;
  elseif (type = "id") then
   set rtn = @id;
  end if;
  set pos = total;
 else
  set pos = pos + 1;
 end if;

 deallocate prepare stmt;
end while;

close col_cur;

end$$
delimiter ;

delimiter $$
create procedure `chk`(in x int, in y int, out ch char(1))
begin
declare c char(1);

select col into c from cols where id = x;

set @sql = 'select ?col? into @ch from ?map? where id = ?y?';
set @sql = replace(@sql, '?map?', @map);
set @sql = replace(@sql, '?col?', c);
set @sql = replace(@sql, '?y?', y);
prepare stmt from @sql;
execute stmt;
set ch = @ch;
deallocate prepare stmt;
end$$
delimiter ;

delimiter $$
create procedure `upd`(in x int, in y int, in ch char(1))
begin
declare c char(1);

select col into c from cols where id = x;

set @sql = 'update ?map? set ?col? = "?ch?" where id = ?y?';
set @sql = replace(@sql, '?map?', @map);
set @sql = replace(@sql, '?col?', c);
set @sql = replace(@sql, '?ch?', ch);
set @sql = replace(@sql, '?y?', y);
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;
end$$
delimiter ;
