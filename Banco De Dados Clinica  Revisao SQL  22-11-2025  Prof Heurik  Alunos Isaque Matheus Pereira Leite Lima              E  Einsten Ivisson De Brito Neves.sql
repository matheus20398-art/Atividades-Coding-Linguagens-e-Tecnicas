
CREATE DATABASE Clinica;
USE Clinica;

CREATE TABLE Ambulatorios (
  nroa INT,
  andar NUMERIC(3) NOT NULL,
  capacidade SMALLINT,
  PRIMARY KEY (nroa)
);

CREATE TABLE Medicos (
  codm INT,
  nome VARCHAR(40) NOT NULL,
  idade SMALLINT NOT NULL,
  especialidade CHAR(20),
  CPF NUMERIC(11) UNIQUE,
  cidade VARCHAR(30),
  nroa INT,
  PRIMARY KEY (codm),
  FOREIGN KEY (nroa) REFERENCES Ambulatorios(nroa)
);

CREATE TABLE Pacientes (
  codp INT,
  nome VARCHAR(40) NOT NULL,
  idade SMALLINT NOT NULL,
  cidade CHAR(30),
  CPF NUMERIC(11) UNIQUE,
  doenca VARCHAR(40) NOT NULL,
  PRIMARY KEY (codp)
);

CREATE TABLE Funcionarios (
  codf INT,
  nome VARCHAR(40) NOT NULL,
  idade SMALLINT,
  CPF NUMERIC(11) UNIQUE,
  cidade VARCHAR(30),
  salario NUMERIC(10),
  cargo VARCHAR(20),
  PRIMARY KEY (codf)
);

CREATE TABLE Consultas (
  codm INT,
  codp INT,
  data DATE,
  hora TIME,
  PRIMARY KEY (codm, codp, data, hora),
  FOREIGN KEY (codm) REFERENCES Medicos(codm),
  FOREIGN KEY (codp) REFERENCES Pacientes(codp)
);

ALTER TABLE Consultas DROP FOREIGN KEY consultas_ibfk_2;

ALTER TABLE Consultas 
ADD CONSTRAINT consultas_ibfk_2
FOREIGN KEY (codp) REFERENCES Pacientes(codp)
ON DELETE CASCADE;

ALTER TABLE Funcionarios ADD COLUMN nroa INT;

CREATE UNIQUE INDEX indMedicos_CPF ON Medicos(CPF);
CREATE INDEX indPacientes_doenca ON Pacientes(doenca);

DROP INDEX indPacientes_doenca ON Pacientes;

ALTER TABLE Funcionarios DROP COLUMN cargo;
ALTER TABLE Funcionarios DROP COLUMN nroa;

INSERT INTO Ambulatorios VALUES
(1,1,30),(2,1,50),(3,2,40),(4,2,25),(5,2,55);

INSERT INTO Medicos VALUES
(1,'Joao',40,'ortopedia',10000100000,'Florianopolis',1),
(2,'Maria',42,'traumatologia',10000110000,'Blumenau',2),
(3,'Pedro',51,'pediatria',11000100000,'São José',2),
(4,'Carlos',28,'ortopedia',11000110000,'Joinville',NULL),
(5,'Marcia',33,'neurologia',11000111000,'Biguacu',3);

INSERT INTO Funcionarios (codf, nome, idade, CPF, cidade, salario) VALUES
(1,'Rita',32,20000100000,'Sao Jose',1200),
(2,'Maria',55,30000110000,'Palhoca',1220),
(3,'Caio',45,41000100000,'Florianopolis',1100),
(4,'Carlos',44,51000110000,'Florianopolis',1200),
(5,'Paula',33,61000111000,'Florianopolis',2500);

INSERT INTO Pacientes VALUES
(1,'Ana',20,'Florianopolis',20000200000,'gripe'),
(2,'Paulo',24,'Palhoca',20000220000,'fratura'),
(3,'Lucia',30,'Biguacu',22000200000,'tendinite'),
(4,'Carlos',28,'Joinville',11000110000,'sarampo');

INSERT INTO Consultas VALUES
(1,1,'2006-06-12','14:00'),
(1,4,'2006-06-13','10:00'),
(2,1,'2006-06-13','09:00'),
(2,2,'2006-06-13','11:00'),
(2,3,'2006-06-14','14:00'),
(2,4,'2006-06-14','17:00'),
(3,1,'2006-06-19','18:00'),
(3,3,'2006-06-12','10:00'),
(3,4,'2006-06-19','13:00'),
(4,4,'2006-06-20','13:00'),
(4,4,'2006-06-22','19:30');

UPDATE Pacientes SET cidade='Ilhota' WHERE nome='Paulo';
UPDATE Consultas SET data='2006-07-04', hora='12:00' WHERE codm=1 AND codp=4;
UPDATE Pacientes SET idade=idade+1, doenca='cancer' WHERE nome='Ana';
UPDATE Consultas SET hora=ADDTIME(hora,'01:30') WHERE codm=3 AND codp=4;
DELETE FROM Funcionarios WHERE codf=4;
DELETE FROM Consultas WHERE hora > '19:00';
DELETE FROM Pacientes WHERE doenca='cancer' OR idade<10;
DELETE FROM Medicos WHERE cidade IN ('Biguacu','Palhoca');

SELECT nome, CPF FROM Medicos WHERE idade < 40 OR especialidade <> 'traumatologia';
SELECT * FROM Consultas WHERE hora BETWEEN '12:00:00' AND '23:59:59' AND data > '2006-06-19';
SELECT nome, idade FROM Pacientes WHERE cidade <> 'Florianopolis';
SELECT hora FROM Consultas WHERE data < '2006-06-14' OR data > '2006-06-20';
SELECT nome, (idade * 12) AS idade_em_meses FROM Pacientes;
SELECT DISTINCT cidade FROM Funcionarios;
SELECT MIN(salario), MAX(salario) FROM Funcionarios WHERE cidade='Florianopolis';
SELECT MAX(hora) FROM Consultas WHERE data='2006-06-13';
SELECT AVG(idade), COUNT(DISTINCT nroa) FROM Medicos;
SELECT codf, nome, salario - (salario*0.20) AS salario_liquido FROM Funcionarios;
SELECT nome FROM Funcionarios WHERE nome LIKE '%a';
SELECT nome, CPF FROM Funcionarios WHERE CPF NOT LIKE '%00000%';
SELECT nome, especialidade FROM Medicos WHERE SUBSTRING(nome,2,1)='o' AND RIGHT(nome,1)='o';
SELECT codp, nome FROM Pacientes WHERE idade > 25 AND doenca IN ('tendinite','fratura','gripe','sarampo');

SELECT m.nome, m.CPF FROM Medicos m WHERE m.CPF IN (SELECT CPF FROM Pacientes);
SELECT f.codf, f.nome, m.codm, m.nome FROM Funcionarios f JOIN Medicos m ON f.cidade=m.cidade;
SELECT DISTINCT p.codp, p.nome FROM Pacientes p JOIN Consultas c ON p.codp=c.codp WHERE c.hora>'14:00';
SELECT DISTINCT a.nroa, a.andar FROM Ambulatorios a JOIN Medicos m ON a.nroa=m.nroa WHERE m.especialidade='ortopedia';
SELECT DISTINCT p.nome, p.CPF FROM Pacientes p JOIN Consultas c ON p.codp=c.codp WHERE c.data BETWEEN '2006-06-14' AND '2006-06-16';
SELECT DISTINCT m.nome, m.idade FROM Medicos m JOIN Consultas c ON m.codm=c.codm JOIN Pacientes p ON p.codp=c.codp WHERE p.nome='Ana';
SELECT DISTINCT m.codm, m.nome FROM Medicos m JOIN Medicos ped ON ped.nome='Pedro' AND m.nroa=ped.nroa JOIN Consultas c ON c.codm=m.codm WHERE c.data='2006-06-14';
SELECT DISTINCT p.nome, p.CPF, p.idade FROM Pacientes p JOIN Consultas c ON p.codp=c.codp JOIN Medicos m ON m.codm=c.codm WHERE m.especialidade='ortopedia' AND c.data<'2006-06-16';
SELECT f2.nome, f2.salario FROM Funcionarios f2 WHERE f2.cidade = (SELECT cidade FROM Funcionarios WHERE codf=4) AND f2.salario > (SELECT salario FROM Funcionarios WHERE codf=4);
SELECT a.*, m.codm, m.nome FROM Ambulatorios a LEFT JOIN Medicos m ON a.nroa=m.nroa ORDER BY a.nroa;
SELECT m.CPF, m.nome, p.CPF, p.nome, c.data FROM Medicos m LEFT JOIN Consultas c ON m.codm=c.codm LEFT JOIN Pacientes p ON p.codp=c.codp ORDER BY m.nome, c.data;

SELECT nome, CPF FROM Medicos WHERE CPF IN (SELECT CPF FROM Pacientes);
SELECT DISTINCT p.codp, p.nome FROM Pacientes p WHERE p.codp IN (SELECT codp FROM Consultas WHERE hora>'14:00');
SELECT DISTINCT m.nome, m.idade FROM Medicos m WHERE m.codm IN (SELECT codm FROM Consultas WHERE codp IN (SELECT codp FROM Pacientes WHERE nome='Ana'));
SELECT nroa, andar FROM Ambulatorios WHERE nroa NOT IN (SELECT DISTINCT nroa FROM Medicos WHERE nroa IS NOT NULL);
SELECT p.nome, p.CPF, p.idade FROM Pacientes p WHERE p.codp IN (SELECT codp FROM Consultas GROUP BY codp HAVING MAX(data)<'2006-06-16');

SELECT nroa, andar FROM Ambulatorios WHERE capacidade > (SELECT MIN(capacidade) FROM Ambulatorios);
SELECT DISTINCT m.nome, m.idade FROM Medicos m WHERE m.codm = ANY (SELECT codm FROM Consultas WHERE codp = (SELECT codp FROM Pacientes WHERE nome='Ana' LIMIT 1));
SELECT nome, idade FROM Medicos ORDER BY idade ASC LIMIT 1;
SELECT DISTINCT p.nome, p.CPF FROM Pacientes p JOIN Consultas c ON p.codp=c.codp WHERE c.hora < ALL (SELECT hora FROM Consultas WHERE data='2006-11-12');
SELECT nome, CPF FROM Medicos WHERE NOT EXISTS (SELECT 1 FROM Ambulatorios a2 WHERE a2.nroa=Medicos.nroa AND a2.capacidade > ALL (SELECT capacidade FROM Ambulatorios WHERE andar=2));

SELECT m.nome, m.CPF FROM Medicos m WHERE EXISTS (SELECT 1 FROM Pacientes p WHERE p.CPF=m.CPF);
SELECT DISTINCT m.nome, m.idade FROM Medicos m WHERE EXISTS (SELECT 1 FROM Consultas c JOIN Pacientes p ON c.codp=p.codp WHERE c.codm=m.codm AND p.nome='Ana');
SELECT a.nroa FROM Ambulatorios a WHERE NOT EXISTS (SELECT 1 FROM Ambulatorios b WHERE b.capacidade>a.capacidade);
SELECT m.nome, m.CPF FROM Medicos m WHERE NOT EXISTS (SELECT 1 FROM Pacientes p WHERE NOT EXISTS (SELECT 1 FROM Consultas c WHERE c.codm=m.codm AND c.codp=p.codp));
SELECT m.nome, m.CPF FROM Medicos m WHERE m.especialidade='ortopedia' AND NOT EXISTS (SELECT 1 FROM Pacientes p WHERE p.cidade='Florianopolis' AND NOT EXISTS (SELECT 1 FROM Consultas c WHERE c.codm=m.codm AND c.codp=p.codp));

SELECT c.* FROM (SELECT codm FROM Medicos WHERE nome='Maria') X JOIN Consultas c ON c.codm=X.codm;
SELECT DISTINCT p.codp, p.nome FROM (SELECT codp FROM Consultas WHERE hora>'14:00:00') X JOIN Pacientes p ON p.codp=X.codp;
SELECT DISTINCT p.nome, p.cidade FROM Pacientes p JOIN (SELECT c.codp FROM Consultas c JOIN Medicos m ON c.codm=m.codm WHERE m.especialidade='ortopedia') X ON p.codp=X.codp;
SELECT p.nome, p.CPF FROM Pacientes p WHERE cidade='Florianopolis' AND p.codp NOT IN (SELECT codp FROM Consultas WHERE codm=(SELECT codm FROM Medicos WHERE nome='Joao' LIMIT 1));

SELECT * FROM Funcionarios ORDER BY salario DESC, idade ASC LIMIT 3;
SELECT m.nome, a.nroa, a.andar FROM Medicos m LEFT JOIN Ambulatorios a ON m.nroa=a.nroa ORDER BY a.nroa;
SELECT m.nome, p.nome, c.data, c.hora FROM Medicos m JOIN Consultas c ON m.codm=c.codm JOIN Pacientes p ON c.codp=p.codp ORDER BY c.data, c.hora;
SELECT idade, COUNT(*) FROM Medicos GROUP BY idade;
SELECT data, COUNT(*) FROM Consultas WHERE hora>'12:00:00' GROUP BY data;
SELECT andar, AVG(capacidade) FROM Ambulatorios GROUP BY andar;
SELECT andar, AVG(capacidade) FROM Ambulatorios GROUP BY andar HAVING AVG(capacidade)>=40;
SELECT m.nome FROM Medicos m JOIN Consultas c ON m.codm=c.codm GROUP BY m.codm, m.nome HAVING COUNT(*)>1;

UPDATE Consultas SET hora='19:00:00' WHERE codp=(SELECT codp FROM Pacientes WHERE nome='Ana' LIMIT 1);
DELETE FROM Pacientes WHERE codp NOT IN (SELECT DISTINCT codp FROM Consultas);
UPDATE Consultas SET data='2006-11-21' WHERE codm=(SELECT codm FROM Medicos WHERE nome='Pedro' LIMIT 1) AND hora<'12:00:00';
UPDATE Ambulatorios SET andar=(SELECT andar FROM Ambulatorios WHERE nroa=1 LIMIT 1), capacidade=2*(SELECT MAX(capacidade) FROM Ambulatorios) WHERE nroa=4;

INSERT INTO Medicos (codm, nome, idade, especialidade, CPF, cidade, nroa)
SELECT 3003, nome, idade, (SELECT especialidade FROM Medicos WHERE codm=2), CPF, cidade, (SELECT nroa FROM Medicos WHERE codm=2)
FROM Funcionarios WHERE codf=3 LIMIT 1;

SELECT * FROM Ambulatorios;
SELECT * FROM Medicos;
SELECT * FROM Pacientes;
SELECT * FROM Funcionarios;
SELECT * FROM Consultas;