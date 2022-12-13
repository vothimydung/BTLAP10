CREATE DATABASE QLSV
GO
USE QLSV
GO
CREATE TABLE Lop(
MaLop NVARCHAR(5) NOT NULL PRIMARY KEY,
TenLop NVARCHAR(20),
SiSo INT
);
GO

CREATE TABLE Sinhvien(
MaSV NVARCHAR(5) NOT NULL PRIMARY KEY,
Hoten NVARCHAR(20),
Ngaysinh DATE,
MaLop NVARCHAR(5) CONSTRAINT fk_malop REFERENCES Lop(malop))
CREATE TABLE MonHoc(
MaMH NVARCHAR(5) NOT NULL PRIMARY KEY,
TenMH NVARCHAR(20));
GO

CREATE TABLE KetQua(
MaSV NVARCHAR(5) NOT NULL,
MaMH NVARCHAR(5) NOT NULL,
Diemthi FLOAT,
CONSTRAINT fk_Masv FOREIGN KEY (MaSV) REFERENCES Sinhvien(MaSV),
CONSTRAINT fk_Mamh FOREIGN KEY (MaMH) REFERENCES MonHoc(MaMH),
CONSTRAINT pk_Masv_Mamh PRIMARY KEY(Masv, mamh));
GO

INSERT INTO Lop(MaLop, TenLop, SiSo) 
VALUES
('A','Lop A',1),
('B','Lop B',2),
('C','Lop C',3)
INSERT INTO Sinhvien(MaSV, Hoten, Ngaysinh, MaLop) 
VALUES
('01','Pham Minh','2002-1-1','A'),
('02','Tran Hung','2002-11-1','B'),
('03','Le Tri','2002-12-12','C')
INSERT INTO MonHoc(MaMH, TenMH)
VALUES
('LTCB','Lap trinh can ban'),
('LTW','Lap trinh web'),
('CSDL','Co so du lieu'),
('PTPM','Phat trien phan mem')
INSERT INTO KetQua(MaSV, MaMH, Diemthi) 
VALUES
('01','LTCB',8),
('02','LTW',7),
('03','PTPM',8),
('01','CSDL',5),
('02','PTW',5),
('03','PTW',5);
GO

--1)
CREATE FUNCTION diemtb (@msv VARCHAR(5))
RETURNS FLOAT
AS
BEGIN
 DECLARE @tb FLOAT
 SET @tb = (SELECT AVG(Diemthi)
 FROM KetQua
WHERE MaSV=@msv)
 RETURN @tb
END
GO
SELECT dbo.diemtb ('01');
GO

--2)
CREATE FUNCTION trbinhlop1(@malop VARCHAR(5))
RETURNS @dsdiemtb TABLE (masv VARCHAR(5), tensv NVARCHAR(20), dtb FLOAT)
AS
BEGIN
 INSERT @dsdiemtb
 SELECT s.masv, Hoten, trungbinh=dbo.diemtb(s.MaSV)
 FROM Sinhvien s INNER JOIN KetQua k ON s.MaSV=k.MaSV
 WHERE MaLop=@malop
 GROUP BY s.masv, Hoten
 RETURN 
END
GO
SELECT * FROM trbinhlop1('A');
GO

--3)
CREATE PROCEDURE ktra @msv NVARCHAR(5)
AS
BEGIN
 DECLARE @n INT
 SET @n=(SELECT COUNT(*) FROM ketqua WHERE Masv=@msv)
 IF @n=0
 PRINT 'Sinh vien '+@msv + 'khong thi mon nao!'
 ELSE
 PRINT 'Sinh vien '+ @msv+ 'thi '+CASR(@n AS NVARCHAR(2))+ 'mon'
END
GO
EXECUTE ktra '01';
GO

--4)
CREATE TRIGGER updatesslop
ON sinhvien
FOR INSERT
AS
BEGIN
 DECLARE @ss INT
 SET @ss=(SELECT COUNT(*) FROM sinhvien s
 WHERE malop IN(SELECT malop FROM inserted))
 IF @ss>10
 BEGIN
 PRINT 'Lop day'
 ROLLBACK TRAN
 END
 ELSE
 BEGIN
 UPDATE lop
 SET SiSo=@ss
 WHERE malop IN (SELECT malop FROM inserted)
 END
 END