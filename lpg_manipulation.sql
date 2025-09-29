--manipulation--
SELECT COUNT(*) FROM Security_In;
SELECT AVG(LPG_Quantity) FROM Security_In;

SELECT Department, AVG(Salary) as avg_sal
FROM HR_Department
GROUP BY Department;


CREATE VIEW Daily_LPG_Report AS
SELECT si.Parking_Date, si.Truck_Type, SUM(si.LPG_Quantity) AS Total_LPG
FROM Security_In si
GROUP BY si.Parking_Date, si.Truck_Type;

select * from Daily_LPG_Report 


--store procedure --
CREATE PROCEDURE GetTruckDetails @Gatepass INT
AS
BEGIN
   SELECT si.Vehicle_Number, si.Driver_Name, wb.Weight_In, wb.Weight_Out, fc.Cylinder_Type
   FROM Security_In si
   LEFT JOIN Weighbridge wb ON si.Gatepass_No_Entry = wb.Gatepass_No
   LEFT JOIN Filling_Center fc ON si.Gatepass_No_Entry = fc.Gatepass_No
   WHERE si.Gatepass_No_Entry = @Gatepass;
END;


exec GetTruckDetails @Gatepass ='1002'

SELECT Parking FROM INFORMATION_SCHEMA.TABLES;
select Security_In from INFORMATION_SCHEMA.TABLES
select * from Parking

--insert value in parking--

insert into Parking
values('AS03BC1504','AV Baruha','Pack',GETDATE(),GETDATE()),
('AS03BC1444','Gogoi','Pack',GETDATE(),GETDATE())


UPDATE Parking
SET Time_Out = DATEADD(HOUR, 1, Time_In)  -- 1 hours after In_Time
WHERE Truck_Number = 'AS03BC1444' AND Time_Out IS NULL;

update Parking
set Time_Out= DATEADD(MINUTE,30,Time_In)
where Truck_Number= 'AS03BC1503'AND Time_Out is null



EXEC sp_help 'Parking';
select * from Security_In


SELECT SYSDATETIMEOFFSET();


select * from Unloading
select count(*) from Unloading
where Truck_Type='Bullet'
group by Capsule1_MT


SELECT Parking_ID, Truck_Number,
       DATEDIFF(HOUR, Time_In, Time_Out) AS Hours_Parked,
       DATEDIFF(MINUTE, Time_In, Time_Out) AS Minutes_Parked
FROM Parking;
select * from Unloading
SELECT Cylinder_Type,Capsule1_MT,
       SUM(Capsule1_MT) OVER (ORDER BY Gatepass_No) AS cylinder_type
  FROM Unloading


 SELECT *
INTO #tempunlaoding
FROM Unloading;

select * from #tempunlaoding

ALTER TABLE #tempunlaoding
ADD bullet_gas_price INT,
    cylinder_price int,
    qunatity_of_cylinder int;

alter table #tempunlaoding
add quantity_of_gas int

UPDATE #tempunlaoding
SET bullet_gas_price = 345090
WHERE  Gatepass_No='1001';


select cylinder_type,Vehicle_Number from #tempunlaoding
where Cylinder_Type  Is not null;

UPDATE #tempunlaoding
SET cylinder_price = 175
WHERE Cylinder_Type='47kg';

UPDATE #tempunlaoding
SET cylinder_price = 140
WHERE Cylinder_Type='19kg';

UPDATE #tempunlaoding
SET cylinder_price = 120
WHERE Cylinder_Type='14kg';


UPDATE #tempunlaoding
SET cylinder_price = 0
WHERE Cylinder_Type is null;


update #tempunlaoding
set bullet_gas_price = 62.66
where Truck_Type ='Bullet'

update #tempunlaoding
set bullet_gas_price = 00
where Truck_Type ='Pack'

UPDATE #tempunlaoding
SET cylinder_price = 0
WHERE Cylinder_Type is null;



update #tempunlaoding
set quantity_of_gas = Capsule1_MT*62
where Truck_Type='bullet'

update #tempunlaoding
set quantity_of_gas = Capsule2_MT*62
where Truck_Type='bullet'

update #tempunlaoding
set quantity_of_gas = Capsule3_MT*62
where Truck_Type='bullet'

select* from #tempunlaoding

update #tempunlaoding
set qunatity_of_cylinder = cylinder_price*47
where Cylinder_Type='47kg'

update #tempunlaoding
set quantity_of_cylinder = cylinder_price*14
where Cylinder_Type='14kg'

update #tempunlaoding
set quantity_of_cylinder = cylinder_price*19
where Cylinder_Type='19kg'



EXEC tempdb.sys.sp_rename '#tempunlaoding.qunatity_of_cylinder', 'quantity_of_cylinder', 'COLUMN';

---Caution: Changing any part of an object name could break scripts and stored procedures.

create table supply_dispatch_unload
(
    Unload_ID INT PRIMARY KEY IDENTITY(1,1),
    Vehicle_Number VARCHAR(50),
    Truck_Type VARCHAR(20),
    Cylinder_Type VARCHAR(10) CHECK (Cylinder_Type IN ('14kg','19kg','47kg')),
    Capsule1_MT DECIMAL(6,2),
    Capsule2_MT DECIMAL(6,2),
    Capsule3_MT DECIMAL(6,2),
    Gatepass_No INT,
    bullet_gas_price int,
    cylinder_price int,
    quantity_of_cylinder int,
    quantity_of_gas int,
    FOREIGN KEY (Gatepass_No) REFERENCES Security_In(Gatepass_No_Entry)
);

INSERT INTO supply_dispatch_unload
(
    Vehicle_Number,
    Truck_Type,
    Cylinder_Type,
    Capsule1_MT,
    Capsule2_MT,
    Capsule3_MT,
    Gatepass_No,
    bullet_gas_price,
    cylinder_price,
    quantity_of_cylinder,
    quantity_of_gas
)
SELECT 
    Vehicle_Number,
    Truck_Type,
    Cylinder_Type,
    Capsule1_MT,
    Capsule2_MT,
    Capsule3_MT,
    Gatepass_No,
    bullet_gas_price,
    cylinder_price,
    quantity_of_cylinder,
    quantity_of_gas
FROM #tempunlaoding;

select * from  supply_dispatch_unload




select* from Loading


---create supply_dispatch_loading table --

create table supply_dispatch_loading
( 
Gatepass_No INT,
cylinder_price int,
cylinder_loaded int,
quantity_of_gas int,

FOREIGN KEY (Gatepass_No) REFERENCES Security_In(Gatepass_No_Entry)
);


INSERT INTO supply_dispatch_loading (Gatepass_No)
SELECT Gatepass_No
FROM Loading;


--join the table and run query--
-- reuire cylinder on left 

SELECT * FROM supply_dispatch_loading s
inner JOIN  Loading l ON s.Gatepass_No = l.Gatepass_No;


--update sd.cylinderprice reference loading table 
UPDATE supply_dispatch_loading 
SET supply_dispatch_loading.cylinder_price = 300
FROM supply_dispatch_loading s
inner JOIN  Loading l ON s.Gatepass_No = l.Gatepass_No
WHERE l.Cylinder_Type = '47kg';


-- using case statement --- 
UPDATE s
SET s.cylinder_price = CASE 
        WHEN l.Cylinder_Type = '47kg' THEN 300
        WHEN l.Cylinder_Type = '19kg' THEN 200
        WHEN l.Cylinder_Type = '14kg' THEN 200
        ELSE s.cylinder_price  -- keep old value if no match
    END
FROM supply_dispatch_loading s
INNER JOIN Loading l ON s.Gatepass_No = l.Gatepass_No;

---uupdate cylinder_loaded in sd

update s
set s.cylinder_loaded =case 
    when l.cylinder_type='47kg' then 220
    when l.cylinder_type='19kg'then 324
    when l.cylinder_type='14kg' then 342
    Else s.cylinder_loaded
    end
from supply_dispatch_loading s
inner join loading l on s.Gatepass_No=l.Gatepass_No

--update quantityofgase insd--

update s 
set s.quantity_of_gas=case
    when l.cylinder_type ='47kg' then cylinder_price*cylinder_loaded
    when l.cylinder_type ='19kg' then cylinder_price*cylinder_loaded
    when l.cylinder_type ='14kg' then cylinder_price*cylinder_loaded
    else s.quantity_of_gas
    end

from supply_dispatch_loading s
inner join loading l on s.Gatepass_No=l.Gatepass_No

create procedure updated_quantity_of_gas
as
begin
update s 
set s.quantity_of_gas=case
    when l.cylinder_type ='47kg' then cylinder_price*cylinder_loaded
    when l.cylinder_type ='19kg' then cylinder_price*cylinder_loaded
    when l.cylinder_type ='14kg' then cylinder_price*cylinder_loaded
    else s.quantity_of_gas
    end

from supply_dispatch_loading s
inner join loading l on s.Gatepass_No=l.Gatepass_No

select * from supply_dispatch_loading

end
go

--call procedure--
exec updated_quantity_of_gas

SELECT Unload_ID,
       Cylinder_Type,
       SUM(Cylinder_Type) OVER
         (PARTITION BY start_terminal ORDER BY start_time)
         AS running_total
  FROM #tempunlaoding
 WHERE Cylinder_Type < '47kg'

--push into github--

  spl.create_date AS [DateCreated],
                                   spl.modify_date AS [DateLastModified]
                                   FROM
                                   sys.registered_search_property_lists AS spl
                                   INNER JOIN sys.database_principals AS dp ON spl.principal_id=dp.principal_id
                                   ORDER BY
                                   [Name] ASC




