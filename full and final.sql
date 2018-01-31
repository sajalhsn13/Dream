drop table record;
drop table donor;
drop table volunteer;
drop table userinfo;

create table userinfo(
	userID number(20) not null,
	name varchar(20),
	email varchar(30),
	phone number(20),
	bloodGroup varchar(10),
	primary key(userID)
);

create table donor(
	donorID number(20) not null,
	userID number(20),
	count number(20) default 0,
	recentDonationDate date,
	primary key(donorID),
	foreign key(userID) references userinfo(userID)
);

create table volunteer(
	volunteerID number(20) not null,
	userID number(20),
	count number(20) default 0,
	primary key(volunteerID),
	foreign key(userID) references userinfo(userID)
);

create table record(
	recordID number(20) not null,
	myDate date,
	volunteerID number(20),
	donorID number(20),
	foreign key (volunteerID) references volunteer(volunteerID),
	foreign key (donorID) references donor(donorID)
);

-- alter table
alter table record add constraint pkr primary key(recordID);

-- trigger
set serveroutput on
create or replace trigger tr_donor
after insert on record
for each row
declare
 	cnt number(20);
begin
	select count into cnt from donor where donorID=:NEW.donorID;
	if inserting then
 		cnt:=cnt+1;
 		update donor set count=cnt where donorID=:NEW.donorID;
	end if;
end;
/

set serveroutput on
create or replace trigger tr_vol
after insert on record
for each row
declare
 	cnt number(20);
begin
	select count into cnt from volunteer where volunteerID=:NEW.volunteerID;
	if inserting then
 		cnt:=cnt+1;
 		update volunteer set count=cnt where volunteerID=:NEW.volunteerID;
	end if;
end;
/

insert into userinfo values(1,'Tusher','Tusher@gmail.com',01711111111,'A+');
insert into userinfo values(2,'Alvi','Alvi@gmail.com',01722222222,'B+');
insert into userinfo values(3,'Shauqi','Shauqi@gmail.com',01733333333,'AB+');
insert into userinfo values(4,'Mosharof','Mosharof@gmail.com',01744444444,'A-');
insert into userinfo values(5,'Xenon','Xenon@gmail.com',01755555555,'B-');
insert into userinfo values(6,'Sakib','Sakib@gmail.com',01766666666,'AB+');
insert into userinfo values(7,'Toufik','Toufik@gmail.com',01777777777,'O-');


insert into volunteer(volunteerID,userID) values(1,1);
insert into volunteer(volunteerID,userID) values(2,3);
insert into volunteer(volunteerID,userID) values(3,4);
insert into volunteer(volunteerID,userID) values(4,7);

insert into donor(donorID,userID) values(1,2);
insert into donor(donorID,userID) values(2,4);
insert into donor(donorID,userID) values(3,5);
insert into donor(donorID,userID) values(4,6);


-- procedure
set serveroutput on
create or replace procedure addRecord(RI record.recordID%type, V record.volunteerID%type, D record.donorID%type) is
	MNT number(20);
	RD date;
	begin
		select recentDonationDate into RD from donor where donorID=D;
		select months_between(RD,sysdate) into MNT from dual;
		if MNT < 4 then
			dbms_output.put_line('4 month is not complete after donating previous time');
		else 
		    insert into record values(RI,sysdate,V,D);
		end if;
	end addRecord;
/
show error;

begin
	addRecord(1,1,2);
	addRecord(2,1,3);
	addRecord(3,3,3);
end;
/

-- function
create OR replace function isDonor(NM userinfo.name%type) return varchar is
   bool varchar(20);
   UID number(20);
begin
	select userID into UID from userinfo where name=NM;
	if UID is not null then
		bool:='YES';
	else
		bool:='NO';
	end if;
	return bool;
end;
/

show error;


begin
	dbms_output.put_line(isDonor('Tusher'));
end;
/


-- update
update record set donorID=4 where volunteerID=1 and donorID=3;


-- show all table
select * from userinfo;
select * from volunteer;
select * from donor;
select * from record;

-- nested query
select userID from donor
	where userID in
		(select userID from volunteer);

-- join
select volunteer.userID from volunteer join donor on volunteer.userID=donor.userID;

-- union
select volunteer.userID from volunteer union select donor.userID from donor;

-- intersect
select volunteer.userID from volunteer intersect select donor.userID from donor;


-- find a record from a specific date
select * from record where myDate>'25-JUL-16' and myDate<'26-JUL-16';

-- cursor
set serveroutput on;
declare
	cursor user_cursor is select name,phone from userinfo where bloodGroup='AB+';
	user_pointer user_cursor%rowtype;
begin
	open user_cursor;
	loop
	fetch user_cursor into user_pointer;
	dbms_output.put_line(user_pointer.name||' '||user_pointer.phone);
	exit when user_cursor%rowcount>1;
	end loop;
	close user_cursor;
end;
/