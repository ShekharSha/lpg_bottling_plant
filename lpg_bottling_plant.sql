--LPG_Bottling_Plant--
create database LPG_Bottling_Plant;
go
use LPG_Bottling_Plant;
go
-- Parking details
CREATE TABLE Parking (
    Parking_ID INT PRIMARY KEY IDENTITY(1,1),
    Truck_Number VARCHAR(20) NOT NULL,
    Driver_Name VARCHAR(100),
    Truck_Type VARCHAR(20) CHECK (Truck_Type IN ('Bullet', 'Pack')),
    Time_In DATETIME,
    Time_Out DATETIME
);
-- Security In
CREATE TABLE Security_In (
    Gatepass_No_Entry INT PRIMARY KEY,
    Parking_Date DATE,
    Vehicle_Number VARCHAR(50) NOT NULL,
    Driver_Name VARCHAR(100),
    Driver_Number CHAR(10),
    Truck_Type VARCHAR(20),
    LPG_Quantity INT
);

-- Security Out
CREATE TABLE Security_Out (
    Gatepass_No_Out INT PRIMARY KEY,
    Parking_Date DATE,
    Vehicle_Number VARCHAR(50) NOT NULL,
    Agency_Name VARCHAR(100) NOT NULL,
    Driver_Name VARCHAR(100),
    Driver_Number CHAR(10),
    Truck_Type VARCHAR(20),
    LPG_Quantity INT
);

-- Weighbridge
CREATE TABLE Weighbridge (
    WB_ID INT PRIMARY KEY IDENTITY(1,1),
    Gatepass_No INT,
    Truck_Type VARCHAR(20),
    Weight_In INT,
    Weight_Out INT,
    In_Time DATETIME,
    Out_Time DATETIME,
    FOREIGN KEY (Gatepass_No) REFERENCES Security_In(Gatepass_No_Entry)
);

-- Unloading
CREATE TABLE Unloading (
    Unload_ID INT PRIMARY KEY IDENTITY(1,1),
    Vehicle_Number VARCHAR(50),
    Truck_Type VARCHAR(20),
    Cylinder_Type VARCHAR(10) CHECK (Cylinder_Type IN ('14kg','19kg','47kg')),
    Capsule1_MT DECIMAL(6,2),
    Capsule2_MT DECIMAL(6,2),
    Capsule3_MT DECIMAL(6,2),
    Gatepass_No INT,
    FOREIGN KEY (Gatepass_No) REFERENCES Security_In(Gatepass_No_Entry)
);

-- Loading
CREATE TABLE Loading (
    Load_ID INT PRIMARY KEY IDENTITY(1,1),
    Truck_Type VARCHAR(20),
    Cylinder_Type VARCHAR(10) CHECK (Cylinder_Type IN ('14kg','19kg','47kg')),
    Gatepass_No INT,
    FOREIGN KEY (Gatepass_No) REFERENCES Security_In(Gatepass_No_Entry)
);

-- Filling Center
CREATE TABLE Filling_Center (
    Fill_ID INT PRIMARY KEY IDENTITY(1,1),
    Cylinder_Type VARCHAR(10) CHECK (Cylinder_Type IN ('5kg','10kg','14.5kg','19kg','47kg')),
    Leakage_Test BIT,
    Cap_Check BIT,
    Manual_Test BIT,
    Gatepass_No INT,
    FOREIGN KEY (Gatepass_No) REFERENCES Security_In(Gatepass_No_Entry)
);

-- HR Department
CREATE TABLE HR_Department (
    Emp_ID INT PRIMARY KEY,
    Employee_Name VARCHAR(100),
    Salary DECIMAL(10,2),
    Hiring_Date DATE,
    Department VARCHAR(50),
    Designation VARCHAR(50)
);
 
