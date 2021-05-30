-- Criacao e populacao de tabelas BD Vendas Produtos Esportivos

/*
cliente ( cod_cli(PK), limite_credito, endereco_cli, fone_cli, situacao_cli, tipo_cli, cod_regiao(fk),pais_cli, nome_fantasia)
cliente_pf (cod_cli_pf(PK)(FK), nome_fantasia, cpf_cli, sexo_cli, profissao_cli)
cliente_pj (cod_cli_pj(PK)(FK), razao_social_cli, cnpj_cli, ramo_atividade_cli)
produto ( cod_prod(PK), nome_prod, descr_prod, categ_esporte(FK), preco_venda, preco_custo, peso, marca(FK), tamanho)
funcionario ( cod_func(PK), nome_func, end_func, cod_depto, sexo_func, dt_admissao, cargo, cod_regiao(fk), cod_func_gerente(FK),
pais_func, salario)
departamento(cod_depto(PK), nome_depto, cod_regiao(FK))
regiao (cod_regiao(PK), nome_regiao)
deposito ( cod_depo(PK), nome_depo, end_depo, cidade_depo, pais_depo, cod_regiao(fk), cod_func_gerente_depo(FK))
pedido ( num_ped(PK), dt_hora_ped, tp_atendimento, vl_total_ped, vl_descto_ped, vl_frete_ped,
 end_entrega, forma_pgto(FK), cod_cli(fk), cod_func_vendedor(fk), situacao_ped)
itens_pedido (num_ped(FK)(PK), cod_prod(fk)(PK), qtde_pedida, descto_item, preco_item, total_item, situacao_item)
forma_pgto (cod_forma(PK), descr_forma_pgto)
armazenamento ( cod_depo(FK)(PK), cod_prod(FK)(PK), qtde_estoque, end_estoque)
marca ( sigla_marca(PK), nome_marca, pais_marca)
pais ( sigla_pais(PK), nome_pais) */

/* parametros de configuracao da sessao */
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS';
ALTER SESSION SET NLS_LANGUAGE = PORTUGUESE;
SELECT SESSIONTIMEZONE, CURRENT_TIMESTAMP FROM DUAL;

-- Sequencias
DROP SEQUENCE pedido_seq;
CREATE SEQUENCE pedido_seq MINVALUE 1 MAXVALUE 9999999 INCREMENT BY 1 START WITH 2020 ;

DROP SEQUENCE produto_seq;
CREATE SEQUENCE produto_seq MINVALUE 1 MAXVALUE 9999999 INCREMENT BY 1 START WITH 5000 ;

-- Tabela regiao
DROP TABLE regiao CASCADE CONSTRAINTS;
CREATE TABLE regiao
(cod_regiao NUMBER(2),
 nome_regiao VARCHAR2(50)
 CONSTRAINT reg_nome_nn NOT NULL,
 CONSTRAINT reg_cod_pk PRIMARY KEY (cod_regiao),
 CONSTRAINT reg_nome_uk UNIQUE (nome_regiao));

INSERT INTO regiao VALUES (1, 'America do Norte');
INSERT INTO regiao VALUES (2, 'America do Sul');
INSERT INTO regiao VALUES (3, 'America Central');
INSERT INTO regiao VALUES (4, 'Africa');
INSERT INTO regiao VALUES (5, 'Asia');
INSERT INTO regiao VALUES (6, 'Europa');

--Tabela CLIENTE
DROP TABLE cliente CASCADE CONSTRAINTS;
CREATE TABLE cliente
(cod_cli INTEGER,
 limite_credito NUMBER(12,2),
 endereco_cli VARCHAR2(400),
 fone_cli CHAR(15),
 situacao_cli CHAR(20),
 tipo_cli CHAR(20),
 cod_regiao NUMBER(2) REFERENCES regiao,
 CONSTRAINT cliente_cod_pk PRIMARY KEY (cod_cli));

ALTER TABLE cliente
 ADD CONSTRAINT chk_tp_cli CHECK ( tipo_cli IN ('PF', 'PJ'));

--Tabela CLIENTE FISICA
DROP TABLE cliente_pf CASCADE CONSTRAINTS;
CREATE TABLE cliente_pf
(cod_cli_pf INTEGER REFERENCES cliente ON DELETE CASCADE,
nome_fantasia VARCHAR2(50) CONSTRAINT cliente_nome_nn NOT NULL,
cpf_cli CHAR(11) not null UNIQUE,
sexo_cli CHAR(1) not null CHECK (sexo_cli IN ('M', 'F')),
profissao_cli CHAR(15),
CONSTRAINT cli_pf_pk PRIMARY KEY (cod_cli_pf));

--Tabela CLIENTE JURIDICA
DROP TABLE cliente_pj CASCADE CONSTRAINTS;
CREATE TABLE cliente_pj
(cod_cli_pj INTEGER REFERENCES cliente ON DELETE CASCADE,
razao_social_cli VARCHAR2(50) CONSTRAINT cliente_rzsoc_nn NOT NULL,
cnpj_cli CHAR(14) not null UNIQUE,
ramo_atividade_cli CHAR(15),
CONSTRAINT cli_pj_pk PRIMARY KEY (cod_cli_pj));

--Tabela funcionario
DROP TABLE funcionario CASCADE CONSTRAINTS;
CREATE TABLE funcionario
(cod_func NUMBER(7),
 nome_func VARCHAR2(25) CONSTRAINT func_nome_nn NOT NULL,
 end_func VARCHAR2(80) NOT NULL,
 sexo_func CHAR(1) CHECK ( sexo_func IN ('M', 'F')),
 dt_admissao DATE,
 cargo CHAR(20) NOT NULL,
 depto CHAR(20) NOT NULL,
 cod_regiao INTEGER NOT NULL REFERENCES regiao,
 CONSTRAINT func_pk PRIMARY KEY (cod_func));

-- Tabela deposito
DROP TABLE deposito CASCADE CONSTRAINTS;
CREATE TABLE deposito
(cod_depo NUMBER(3) CONSTRAINT deposito_cod_pk PRIMARY KEY ,
 nome_depo VARCHAR2(30) NOT NULL,
 end_depo VARCHAR2(100),
 cidade_depo VARCHAR2(30),
 pais_depo CHAR(20),
 cod_regiao INTEGER NOT NULL REFERENCES regiao,
 cod_func_gerente_depo NUMBER(7) REFERENCES funcionario);

-- Tabela PRODUTO
DROP TABLE produto CASCADE CONSTRAINTS;
CREATE TABLE produto
(cod_prod NUMBER(7) CONSTRAINT prod_cod_pk PRIMARY KEY,
 nome_prod VARCHAR2(50) CONSTRAINT prod_nome_nn NOT NULL,
 descr_prod VARCHAR2(255),
 categ_esporte CHAR(20),
 preco_venda NUMBER(11, 2),
 preco_custo NUMBER(11, 2),
 peso NUMBER(5,2),
 marca CHAR(15) NOT NULL,
 CONSTRAINT prod_nome_uq UNIQUE (nome_prod));

 ALTER TABLE produto ADD tamanho CHAR(3) ;

-- Tabela PEDIDO
DROP TABLE pedido CASCADE CONSTRAINTS;
CREATE TABLE pedido
(num_ped INTEGER CONSTRAINT ped_cod_pk PRIMARY KEY,
 dt_hora_ped TIMESTAMP NOT NULL,
 tp_atendimento CHAR(10),
 vl_total_ped NUMBER(11, 2),
 vl_descto_ped NUMBER(11, 2),
 vl_frete_ped NUMBER(11, 2),
 end_entrega VARCHAR2(80),
 forma_pgto CHAR(20),
 cod_cli INTEGER NOT NULL REFERENCES cliente,
 cod_func_vendedor NUMBER(7) REFERENCES funcionario);

--Tabela ARMAZENAMENTO
DROP TABLE armazenamento CASCADE CONSTRAINTS;
CREATE TABLE armazenamento
(cod_depo NUMBER(3) NOT NULL REFERENCES deposito ON DELETE CASCADE,
 cod_prod NUMBER(7) NOT NULL REFERENCES produto ON DELETE CASCADE,
 qtde_estoque NUMBER(5),
 end_estoque VARCHAR2(25),
CONSTRAINT armazenamento_pk PRIMARY KEY (cod_depo, cod_prod));

-- Tabela itens_pedido
DROP TABLE itens_pedido CASCADE CONSTRAINTS;
CREATE TABLE itens_pedido
(num_ped INTEGER REFERENCES pedido (num_ped) ON DELETE CASCADE,
 cod_prod NUMBER(7) REFERENCES produto (cod_prod) ON DELETE CASCADE,
 qtde_itens_pedido NUMBER(3),
 descto_itens_pedido NUMBER(5,2) ,
 CONSTRAINT itemped_pk PRIMARY KEY (num_ped, cod_prod));

-- Tabela Pais
DROP TABLE pais CASCADE CONSTRAINTS ;
CREATE TABLE pais
( sigla_pais CHAR(3) PRIMARY KEY,
nome_pais VARCHAR2(50) NOT NULL) ;

INSERT INTO pais VALUES ( 'BRA' , 'Brasil') ;
INSERT INTO pais VALUES ( 'EUA' , 'Estados Unidos da America') ;
INSERT INTO pais VALUES ( 'JAP' , 'Japao') ;
INSERT INTO pais VALUES ( 'ALE' , 'Alemanha') ;
INSERT INTO pais VALUES ( 'GBR' , 'Gra-Bretanha') ;
INSERT INTO pais VALUES ( 'IND' , 'India') ;
INSERT INTO pais VALUES ( 'CHI' , 'China') ;
INSERT INTO pais VALUES ( 'FRA' , 'Franca') ;
INSERT INTO pais VALUES ( 'ESP' , 'Espanha') ;

INSERT INTO pais VALUES ( 'ARG' , 'Argentina') ;
INSERT INTO pais VALUES ( 'URU' , 'Uruguai') ;
INSERT INTO pais VALUES ( 'POR' , 'Portugal') ;
INSERT INTO pais VALUES ( 'ITA' , 'Italia') ;
INSERT INTO pais VALUES ( 'COR' , 'Coreia do Sul') ;
INSERT INTO pais VALUES ( 'CAN' , 'Canada') ;


-- Tabela Marca
DROP TABLE marca cascade constraints;
CREATE TABLE marca
( sigla_marca CHAR(3) NOT NULL constraint fabr_sigla_pk PRIMARY KEY,
nome_marca VARCHAR2(30) NOT NULL,
pais_marca CHAR(3) NOT NULL REFERENCES pais (sigla_pais) ) ;

INSERT INTO marca VALUES ('NIK' , 'NIKE' , 'EUA') ;
INSERT INTO marca VALUES ('MZN' , 'MIZUNO' , 'JAP') ;
INSERT INTO marca VALUES ('ADI' , 'ADIDAS' , 'ALE') ;
INSERT INTO marca VALUES ('RBK' , 'REBOOK' , 'EUA') ;
INSERT INTO marca VALUES ('PUM' , 'PUMA' , 'ALE') ;
INSERT INTO marca VALUES ('TIM' , 'TIMBERLAND' , 'EUA') ;
INSERT INTO marca VALUES ('WLS' , 'WILSON' , 'EUA') ;
INSERT INTO marca VALUES ('UMB' , 'UMBRO' , 'GBR') ;
INSERT INTO marca VALUES ('ASI' , 'ASICS' , 'JAP') ;
INSERT INTO marca VALUES ('PEN' , 'PENALTY' , 'BRA') ;
INSERT INTO marca VALUES ('UAR' , 'UNDER ARMOUR' , 'EUA') ;
INSERT INTO marca VALUES ('LOT' , 'LOTO' , 'ITA') ;

ALTER TABLE produto MODIFY marca CHAR(3) REFERENCES marca ( sigla_marca) ;

-- Tabela categoria esportiva
DROP TABLE categ_esporte cascade constraints;
CREATE TABLE categ_esporte
( categ_esporte CHAR(4) NOT NULL constraint mod_tp_pk PRIMARY KEY,
nome_esporte VARCHAR2(30) NOT NULL ) ;

INSERT INTO categ_esporte VALUES ('FUTB' , 'Futebol de campo') ;
INSERT INTO categ_esporte VALUES ('BASQ' , 'Basquetebol') ;
INSERT INTO categ_esporte VALUES ('VOLQ' , 'Voleibol de quadra') ;
INSERT INTO categ_esporte VALUES ('CORR' , 'Corrida e Caminhada') ;
INSERT INTO categ_esporte VALUES ('TENQ' , 'Tenis de quadra') ;
INSERT INTO categ_esporte VALUES ('MARC' , 'Artes Marciais') ;
INSERT INTO categ_esporte VALUES ('CASU' , 'Casual') ;
INSERT INTO categ_esporte VALUES ('SKAT' , 'Skate') ;

ALTER TABLE produto MODIFY categ_esporte CHAR(4) REFERENCES categ_esporte ( categ_esporte) ;
ALTER TABLE produto MODIFY categ_esporte NOT NULL ;

-- Tabela CARGO
DROP TABLE cargo CASCADE CONSTRAINTS;
CREATE TABLE cargo
( cod_cargo NUMBER(2) CONSTRAINT cargo_cargo_pk PRIMARY KEY,
nome_cargo VARCHAR2(25));

INSERT INTO cargo VALUES (01,'Presidente');
INSERT INTO cargo VALUES (02, 'Vendedor');
INSERT INTO cargo VALUES (03, 'Operador de Estoque');
INSERT INTO cargo VALUES (04, 'VP, Administracao');
INSERT INTO cargo VALUES (05, 'VP, Financeiro');
INSERT INTO cargo VALUES (06, 'Auxiliar Administrativo');
INSERT INTO cargo VALUES (07, 'Atendente');
INSERT INTO cargo VALUES (08, 'Gerente de Deposito');
INSERT INTO cargo VALUES (09, 'Gerente de Vendas');
INSERT INTO cargo VALUES (10, 'Gerente Financeiro');
INSERT INTO cargo VALUES (11, 'Gerente Tecnologia');
INSERT INTO cargo VALUES (12, 'Analista Suporte');
INSERT INTO cargo VALUES (13, 'Desenvolvedor');

descr funcionario ;
ALTER TABLE funcionario MODIFY cargo NUMBER(2) REFERENCES cargo ;
ALTER TABLE funcionario RENAME COLUMN cargo TO cod_cargo ;

-- Tabela DEPTO
DROP TABLE departamento CASCADE CONSTRAINTS;
CREATE TABLE departamento
(cod_depto NUMBER(7),
 nome_depto VARCHAR2(30) CONSTRAINT depto_nome_nn NOT NULL,
 cod_regiao NUMBER(2) REFERENCES regiao (cod_regiao),
 CONSTRAINT depto_cod_pk PRIMARY KEY (cod_depto));

 SELECT * FROM regiao ;

INSERT INTO departamento VALUES (10, 'Financeiro', 1);
INSERT INTO departamento VALUES (11, 'Financeiro', 2);
INSERT INTO departamento VALUES (12, 'Financeiro', 3);
INSERT INTO departamento VALUES (13, 'Financeiro', 4);
INSERT INTO departamento VALUES (14, 'Financeiro', 5);
INSERT INTO departamento VALUES (31, 'Vendas', 1);
INSERT INTO departamento VALUES (32, 'Vendas', 2);
INSERT INTO departamento VALUES (33, 'Vendas', 3);
INSERT INTO departamento VALUES (34, 'Vendas', 4);
INSERT INTO departamento VALUES (35, 'Vendas', 5);
INSERT INTO departamento VALUES (36, 'Vendas', 6);
INSERT INTO departamento VALUES (41, 'Estoque', 1);
INSERT INTO departamento VALUES (42, 'Estoque', 2);
INSERT INTO departamento VALUES (43, 'Estoque', 3);
INSERT INTO departamento VALUES (44, 'Estoque', 4);
INSERT INTO departamento VALUES (45, 'Estoque', 5);
INSERT INTO departamento VALUES (50, 'Administracao', 1);
INSERT INTO departamento VALUES (51, 'Administracao', 2);
INSERT INTO departamento VALUES (22, 'Tecnologia da Informacao', 1);
INSERT INTO departamento VALUES (23, 'Tecnologia da Informacao', 2);

descr funcionario;
ALTER TABLE funcionario MODIFY depto NUMBER(7) REFERENCES departamento;
ALTER TABLE funcionario RENAME COLUMN depto TO cod_depto;

-- Tabela Forma de pagamento
DROP TABLE forma_pgto CASCADE CONSTRAINTS;
CREATE TABLE forma_pgto
( cod_forma CHAR(6) PRIMARY KEY,
descr_forma_pgto VARCHAR2(30)) ;

INSERT INTO forma_pgto VALUES ( 'DIN', 'Dinheiro') ;
INSERT INTO forma_pgto VALUES ( 'CTCRED', 'Cartao de Credito') ;
INSERT INTO forma_pgto VALUES ( 'TICKET', 'Vale refeicao') ;
INSERT INTO forma_pgto VALUES ( 'DEBITO', 'Debito em conta') ;

-- transformando em FK no pedido
ALTER TABLE pedido MODIFY forma_pgto CHAR(6) REFERENCES forma_pgto ;
ALTER TABLE pedido MODIFY forma_pgto NOT NULL ;

-- Adicionando auto-relacionamento a funcionario
ALTER TABLE funcionario
 ADD cod_func_gerente NUMBER(7) REFERENCES funcionario (cod_func) ;

-- relacionando deposito com o pais
ALTER TABLE deposito MODIFY pais_depo CHAR(3) REFERENCES pais ;

--nova coluna em Pedido com a Situação;
ALTER TABLE pedido ADD situacao_ped CHAR(15) CHECK
( situacao_ped IN ('APROVADO', 'REJEITADO', 'EM SEPARACAO', 'DESPACHADO', 'ENTREGUE', 'CANCELADO'));

--nova coluna em Cliente e em Funcionário com o País e relacione com a tabela correspondente;
ALTER TABLE cliente ADD pais_cli CHAR(3) REFERENCES pais ;
ALTER TABLE funcionario ADD pais_func CHAR(3) REFERENCES pais ;

/* constraints de verificação :
	Situação em Cliente : Ativo, Inativo, Suspenso */
ALTER TABLE cliente ADD CHECK ( situacao_cli IN ('ATIVO', 'INATIVO', 'SUSPENSO'));

--Preço de venda maior ou igual a preço de custo
ALTER TABLE produto ADD CHECK ( preco_venda >= preco_custo) ;

--Valores e quantidades nunca com valor negativo
ALTER TABLE produto ADD CHECK ( preco_venda >= 0) ;
ALTER TABLE produto ADD CHECK ( preco_custo >= 0) ;
ALTER TABLE pedido ADD CHECK ( vl_total_ped >= 0) ;
ALTER TABLE pedido ADD CHECK ( vl_descto_ped >= 0) ;
ALTER TABLE pedido ADD CHECK ( vl_frete_ped >= 0) ;
ALTER TABLE itens_pedido ADD CHECK ( qtde_itens_pedido > 0) ;

-- Renomeando coluna;
ALTER TABLE itens_pedido RENAME COLUMN qtde_itens_pedido to qtde_pedida ;
ALTER TABLE itens_pedido RENAME COLUMN descto_itens_pedido to descto_item ;

-- coluna CHAR para VARCHAR;
ALTER TABLE cliente_pf MODIFY profissao_cli VARCHAR2(20) ;

-- valores default para todas as colunas que indiquem Valor e para a data e hora do pedido.
ALTER TABLE pedido MODIFY vl_descto_ped DEFAULT 0.0 ;

/**********************************************************
populacao das tabelas
***********************************************************/
-- cliente
descr cliente ;
INSERT INTO cliente VALUES ( 200, 1000, '72 Via Bahia', '123456', 'ATIVO', 'PF', 2, 'BRA');
INSERT INTO cliente VALUES ( 201, 2000, '6741 Takashi Blvd.', '81-20101','ATIVO','PJ', 5, 'JAP');
INSERT INTO cliente VALUES ( 202, 5000, '11368 Chanakya', '91-10351', 'ATIVO','PJ', 5, 'IND');
INSERT INTO cliente VALUES ( 203, 2500, '281 King Street', '1-206-104-0103', 'ATIVO','PJ', 1,'EUA');
INSERT INTO cliente VALUES ( 204, 3000, '15 Henessey Road', '852-3692888','ATIVO','PJ', 5,'CHI' );
INSERT INTO cliente VALUES ( 205, 4000, '172 Rue de Rivoli', '33-2257201', 'ATIVO','PJ', 6,'FRA');
INSERT INTO cliente VALUES ( 206, 1800, '6 Saint Antoine', '234-6036201', 'ATIVO','PJ', 6,'FRA');
INSERT INTO cliente VALUES ( 207, 3800, '435 Gruenestrasse', '49-527454','ATIVO','PJ', 6,'ALE');
INSERT INTO cliente VALUES ( 208, 6000, '792 Playa Del Mar','809-352689', 'ATIVO','PJ', 6,'ESP');
INSERT INTO cliente VALUES ( 209, 3000, '3 Via Saguaro', '52-404562', 'ATIVO','PF', 6,'ESP');
INSERT INTO cliente VALUES ( 210, 3500, '7 Modrany', '42-111292','ATIVO','PF', 6,'ALE' );
INSERT INTO cliente VALUES ( 211, 5500, '2130 Granville', '52-1876292','ATIVO','PJ', 1,'CAN' );
INSERT INTO cliente VALUES ( 212, 4200, 'Via Rosso 677', '72-2311292','ATIVO','PF', 6,'ITA' );
INSERT INTO cliente VALUES ( 213, 3200, 'Libertad 400', '97-311543','ATIVO','PF', 2,'ARG' );
INSERT INTO cliente VALUES ( 214, 2100, 'Maldonado 120', '96-352943','ATIVO','PJ', 2,'URU' );

-- pf
INSERT INTO cliente_pf VALUES ( 200, 'Joao Avila', 033123, 'M', 'Arquiteto');
INSERT INTO cliente_pf VALUES ( 209, 'Katrina Shultz', 173623, 'F', 'Medica');
INSERT INTO cliente_pf VALUES ( 210, 'Gunter Schwintz', 826363, 'M', 'Professor');
INSERT INTO cliente_pf VALUES ( 212, 'Luigi Forlani', 876521, 'M', 'Maestro');
INSERT INTO cliente_pf VALUES ( 213, 'Sabrina Lescano', 562378, 'F', 'Designer');
-- pj
INSERT INTO cliente_pj VALUES ( 201, 'Hamses Distribuidora SC', 7654321, 'Distribuidora') ;
INSERT INTO cliente_pj VALUES ( 202, 'Ementhal Comercio Ltda', 9876321, 'Comercio') ;
INSERT INTO cliente_pj VALUES ( 203, 'Picture Bow', 9865411, 'Comercio') ;
INSERT INTO cliente_pj VALUES ( 204, 'Saturn Sports INC', 73634646, 'Comercio') ;
INSERT INTO cliente_pj VALUES ( 205, 'Ping Tong Sam', 35352656, 'Comercio') ;
INSERT INTO cliente_pj VALUES ( 206, 'Pasadena Esportes', 73657126, 'Comercio') ;
INSERT INTO cliente_pj VALUES ( 207, 'Weltashung Sportif', 187908098, 'Comercio') ;
INSERT INTO cliente_pj VALUES ( 208, 'Random Realey Company', 76325943, 'Comercio') ;
INSERT INTO cliente_pj VALUES ( 211, 'London Drugs', 16721563, 'Comercio') ;
INSERT INTO cliente_pj VALUES ( 214, 'Empanadas con Vino', 90312876, 'Distribuidora') ;
-- nome fantasia
alter table cliente add nome_fantasia varchar2(30) ;

UPDATE cliente c
SET c.nome_fantasia = ( SELECT SUBSTR(nome_fantasia, 1, INSTR(nome_fantasia,' ')- 1) FROM cliente_pf
WHERE cod_cli_pf = c.cod_cli )
WHERE c.tipo_cli = 'PF' ;

UPDATE cliente c
SET c.nome_fantasia = ( SELECT SUBSTR(razao_social_cli, 1, INSTR(razao_social_cli,' ')- 1) FROM cliente_pj
WHERE cod_cli_pj = c.cod_cli )
WHERE c.tipo_cli = 'PJ' ;

-- salario em funcionario
alter table funcionario add salario number(10,2) ;
DESCR funcionario ;
INSERT INTO funcionario VALUES ( 1, 'Alessandra Mariano', 'Rua A,10', 'F', '03-03-2000', 11,12, 3, null, 'BRA', 2100);
INSERT INTO funcionario VALUES ( 2, 'James Smith', 'Rua B,20', 'M', '08-03-2000', 10, 12, 3, null, 'EUA', 6000);
INSERT INTO funcionario VALUES ( 3, 'Kraus Schumann', 'Rua C,100','M', '17-06-2000', 10, 36, 6, 2, 'ALE',4200 );
INSERT INTO funcionario VALUES ( 4, 'Kurota Issa', 'Rua D,23', 'F','07-04-2000', 2, 35, 5 , null, 'JAP',6450);
INSERT INTO funcionario VALUES ( 5, 'Cristina Moreira', 'Rua Abc,34', 'F','04-03-2000', 3, 35, 5, 4, 'BRA', 4000);
INSERT INTO funcionario VALUES ( 6, 'Jose Silva', 'Av. Sete, 10', 'M','18-01-2001', 12, 41,3, NULL, 'BRA', 3200);
INSERT INTO funcionario VALUES ( 7, 'Roberta Pereira', 'Largo batata, 200', 'F','14-05-2000', 12, 33, 3, 1, 'EUA', 5300);
INSERT INTO funcionario VALUES ( 8, 'Alex Alves', 'Rua Dabliu, 10','M','07-04-2000', 2, 12, 1, 3, 'BRA', 2900);
INSERT INTO funcionario VALUES ( 9, 'Isabela Matos', 'Rua Ipsilone, 20', 'F','09-02-2001',2, 42, 6,4, 'EUA', 3200);
INSERT INTO funcionario VALUES (10, 'Matheus De Matos','Av. Beira-Mar, 300', 'M','27-02-2001', 2, 51,5,2, 'ESP',4000);
INSERT INTO funcionario VALUES (11, 'Wilson Borga', 'Travessa Circular', 'M','14-05-2000', 2, 33, 3,3,'BRA', 3150);

INSERT INTO funcionario VALUES (12, 'Marco Rodrigues', 'Rua Beta, 20', 'M', '18-01-2000', 8, 43, 1, 1, 'URU', 3400);
INSERT INTO funcionario VALUES (13, 'Javier Hernandez', 'Calle Sur, 20','M', '18-02-2000', 3, 51, 3, 3, 'ARG', 4210);
INSERT INTO funcionario VALUES (14, 'Chang Shung Dao', 'Dai Kai, 300', 'F', '22-01-2001', 10, 12, 2, 2, 'CHI', 3980);
INSERT INTO funcionario VALUES (15, 'Simon Holowitz', '19th Street','M', '09-10-2001',3, 14, 6, 6, 'GBR', 5460);

INSERT INTO funcionario VALUES (16, 'Penelope Xavier', 'Calle Paraguay, 20', 'F', '12-11-2003', 8, 43, 1, 1, 'URU', 2400);
INSERT INTO funcionario VALUES (17, 'Esmeralda Soriano', 'Calle Peru, 40','F', '18-12-2006', 3, 51, 3, 3, 'ARG', 4710);
INSERT INTO funcionario VALUES (18, 'Ari Gato Sam', 'Yakisoba, 300', 'M', '21-01-2011', 10, 12, 2, 2, 'CHI', 1980);
INSERT INTO funcionario VALUES (19, 'Hannah Arendt', '22th South Avenue','F', '19-11-2011',3, 14, 6, 6, 'CAN', 4460);

descr deposito;
INSERT INTO deposito VALUES ( 101, 'Warehouse Bull', '283 King Street', 'Seattle', 'EUA', 1, 1);
INSERT INTO deposito VALUES ( 105, 'Deutsch Store','Friederisch Strasse', 'Berlim','ALE',6, 3);
INSERT INTO deposito VALUES ( 201, 'Santao','68 Via Anchieta', 'Sao Paulo', 'BRA', 2, 7);
INSERT INTO deposito VALUES ( 301, 'NorthWare', '6921 King Way', 'Nova Iorque', 'EUA', 1, 8);
INSERT INTO deposito VALUES ( 401, 'Daiso Han', '86 Chu Street', 'Tokio', 'JAP', 5, 9);
INSERT INTO deposito VALUES ( 302, 'RailStore', '234 Richards', 'Vancouver', 'CAN', 1, 8);
INSERT INTO deposito VALUES ( 402, 'Daiwu Son', 'Heyjunka 200', 'Seul', 'COR', 5, 9);

/*********** Produto ***********/
INSERT INTO produto VALUES ( produto_seq.nextval, 'Chuteira Total 90', 'Chuteira Total 90 Shoot TF', 'FUTB', 169, 132, 290,'NIK', null);
INSERT INTO produto VALUES ( produto_seq.nextval, 'Chuteira Absolado TRX', 'Chuteira Absolado TRX FG', 'FUTB',279,210,321, 'ADI', null );
INSERT INTO produto VALUES ( produto_seq.nextval, 'Agasalho Total 90', 'Agasalho Total 90', 'FUTB',199,121,420, 'NIK', null);
INSERT INTO produto VALUES ( produto_seq.nextval, 'Bola Copa do Mundo', 'Bola Futebol Copa do Mundo Oficial 2006', 'FUTB',56.25,32,390, 'ADI', null );
INSERT INTO produto VALUES ( produto_seq.nextval, 'Camisa Real Madrid', 'Camisa Oficial Real Madrid I Ronaldinho', 'FUTB',99.95,62, 190,'ADI', null );
INSERT INTO produto VALUES ( produto_seq.nextval, 'Meia Drift 3/4', 'Meia Esportiva', 'CORR', 22.95,16, 160, 'NIK', null);

INSERT INTO produto VALUES (produto_seq.nextval, 'T-Shirt Run Power', 'Camiseta Dry Fit', 'CORR', 69, 51, 145,'MZN','M');
INSERT INTO produto VALUES ( produto_seq.nextval, 'Calcao Dighton', 'Calcao Running Dighton','CORR', 38, 27, 100, 'MZN','P');
INSERT INTO produto VALUES ( produto_seq.nextval, 'Tenis Stratus 2.1','Tenis Corrida Stratus 2.1', 'CORR', 293,242, 258, 'ASI','42');
INSERT INTO produto VALUES ( produto_seq.nextval, 'Tenis Actual', 'Tenis Actual Alto Impacto', 'CORR', 399, 320, 278,'RBK',null );
INSERT INTO produto VALUES ( produto_seq.nextval, 'Tenis Advantage Court III', 'Tenis Advantage Court III', 'CASU', 98, 70, 241, 'WLS', '40');
INSERT INTO produto VALUES ( produto_seq.nextval, 'Tenis Slim Racer Woman', 'Tenis Corrida Feminino Slim Racer', 'CORR', 199, 165, 189, 'RBK', '37' );

INSERT INTO produto VALUES (produto_seq.nextval , 'Caneleira F50 Replique 2008', 'Caneleira Futebol F50 Replique 2008','FUTB', 49, 37, 120, 'ADI','U' );
INSERT INTO produto VALUES (produto_seq.nextval, 'Luvas F50 Training', 'Luvas Adidas F50 Training', 'FUTB', 69, 52.78, 85, 'ADI', 'U' );
INSERT INTO produto VALUES (produto_seq.nextval, 'Tenis Asics Gel Kambarra III', 'Tenis Corrida Gel Kambarra III Masculino',  'CORR', 199,143, 210, 'ASI',41);
INSERT INTO produto VALUES (produto_seq.nextval, 'Tenis Asics Gel Maverick 2', 'Tenis Corrida Gel Maverick 2',  'CORR', 159,129.90, 206, 'ASI','42');
INSERT INTO produto VALUES (produto_seq.nextval, 'Tenis Puma Elevation II', 'Tenis Puma Elevation II Feminino',  'CASU', 129, 98.75, 230, 'PUM', '42');
INSERT INTO produto VALUES (produto_seq.nextval , 'Blusao Adidas F50 Formotion', 'Blusao Adidas F50 Formotion', 'FUTB', 199, 159.90, 320, 'ADI', 'XG');
INSERT INTO produto VALUES (produto_seq.nextval, 'Tenis Puma Alacron II','Tenis Puma Alacron II' ,  'CASU', 165, 128.55, 210, 'PUM', '43');
INSERT INTO produto VALUES (produto_seq.nextval , 'Tenis Aventura RG Hike', 'Tenis Aventura RG Hike', 'CORR', 269, 201.55, 240,  'TIM', '42');
INSERT INTO produto VALUES (produto_seq.nextval , 'Tenis Aventura Gorge C2', 'Tenis Aventura Gorge C2',  'CORR', 229, 175.24, 198,  'TIM', '41');
INSERT INTO produto VALUES (produto_seq.nextval, 'Bola Varsity', 'Bola Varsity', 'BASQ', 22, 15.75, 265, 'WLS', 'u');

INSERT INTO produto VALUES (produto_seq.nextval , 'Camiseta U40', 'Camiseta U40', 'SKAT', 75, 62.30, 320, 'LOT', 'G');
INSERT INTO produto VALUES (produto_seq.nextval, 'Bermuda Corrida','Bermuda Corrida DriFit' ,  'CORR', 105, 90.55, 210, 'UAR', 'M');
INSERT INTO produto VALUES (produto_seq.nextval , 'Camiseta Regata NBA', 'Camiseta Regata NBA', 'BASQ', 169, 101.35, 240,  'NIK', 'G');
INSERT INTO produto VALUES (produto_seq.nextval , 'Truck 5pol', 'Truck 5 polegadas LongBoard',  'SKAT', 129, 85.24, 198,  'ADI', 'u');
INSERT INTO produto VALUES (produto_seq.nextval, 'Bola NBA', 'Bola NBA', 'BASQ', 72,  65.75, 265, 'NIK', 'u');

-- armazenamento
INSERT INTO armazenamento VALUES ( 101, 5001, 650, 'A0123');
INSERT INTO armazenamento VALUES ( 101, 5002, 150, 'B0123');
INSERT INTO armazenamento VALUES ( 101, 5003, 650, 'C0123');
INSERT INTO armazenamento VALUES ( 101, 5004, 650, 'D0123');
INSERT INTO armazenamento VALUES ( 101, 5005, 610, 'E0123');
INSERT INTO armazenamento VALUES ( 101, 5006, 650, 'F0123');
INSERT INTO armazenamento VALUES ( 101, 5007, 250, 'G0123');
INSERT INTO armazenamento VALUES ( 101, 5008, 650, 'H0123');
INSERT INTO armazenamento VALUES ( 101, 5009, 650, 'I0123');
INSERT INTO armazenamento VALUES ( 101, 5010, 650, 'J0123');

INSERT INTO armazenamento VALUES ( 101, 5015, 50, 'J0123');
INSERT INTO armazenamento VALUES ( 101, 5016, 50, 'W0113');
INSERT INTO armazenamento VALUES ( 101, 5017, 50, 'U0123');
INSERT INTO armazenamento VALUES ( 101, 5018, 150, 'A0143');

INSERT INTO armazenamento VALUES ( 105, 5001, 650, 'A0123');
INSERT INTO armazenamento VALUES ( 105, 5002, 150, 'B0123');
INSERT INTO armazenamento VALUES ( 105, 5003, 650, 'C0123');
INSERT INTO armazenamento VALUES ( 105, 5004, 650, 'D0123');
INSERT INTO armazenamento VALUES ( 105, 5005, 610, 'E0123');
INSERT INTO armazenamento VALUES ( 105, 5006, 650, 'F0123');
INSERT INTO armazenamento VALUES ( 105, 5007, 250, 'G0123');
INSERT INTO armazenamento VALUES ( 105, 5008, 650, 'H0123');
INSERT INTO armazenamento VALUES ( 105, 5009, 650, 'I0123');
INSERT INTO armazenamento VALUES ( 105, 5010, 650, 'J0123');
INSERT INTO armazenamento VALUES ( 105, 5011, 650, 'K0123');

INSERT INTO armazenamento VALUES ( 105, 5017, 50, 'G0223');
INSERT INTO armazenamento VALUES ( 105, 5018, 50, 'H0323');
INSERT INTO armazenamento VALUES ( 105, 5019, 50, 'I0423');
INSERT INTO armazenamento VALUES ( 105, 5020, 50, 'J0323');
INSERT INTO armazenamento VALUES ( 105, 5021, 50, 'K0223');
-- Pedido
INSERT INTO pedido VALUES ( pedido_seq.nextval, current_timestamp - 130,'FONE' , 200, 0, 5, 'O MESMO', 'CTCRED', 200, 8,'EM SEPARACAO');
INSERT INTO pedido VALUES ( pedido_seq.nextval, current_timestamp - 100,'FONE' , 200, 0, 5, 'O MESMO', 'CTCRED', 211, 4,'EM SEPARACAO');
INSERT INTO pedido VALUES ( pedido_seq.nextval, current_timestamp - 90,'FONE' , 300, 0, 5, 'O MESMO', 'CTCRED', 201, 8,'EM SEPARACAO');
INSERT INTO pedido VALUES ( pedido_seq.nextval, current_timestamp - 80,'FONE' , 400, 0, 5, 'O MESMO', 'DEBITO', 202, 10,'EM SEPARACAO');
INSERT INTO pedido VALUES ( pedido_seq.nextval, current_timestamp - 70,'FONE' , 210, 0, 5, 'O MESMO', 'CTCRED', 203, 8,'EM SEPARACAO');
INSERT INTO pedido VALUES ( pedido_seq.nextval, current_timestamp - 60,'FONE' , 600, 0, 5, 'O MESMO', 'CTCRED', 204, 4,'EM SEPARACAO');
INSERT INTO pedido VALUES ( pedido_seq.nextval, current_timestamp - 55,'FONE' , 280, 0, 5, 'O MESMO', 'DEBITO', 214, 11,'EM SEPARACAO');
INSERT INTO pedido VALUES ( pedido_seq.nextval, current_timestamp - 50,'FONE' , 280, 0, 5, 'O MESMO', 'CTCRED', 208, 8,'EM SEPARACAO');
INSERT INTO pedido VALUES ( pedido_seq.nextval, current_timestamp - 40,'FONE' , 1200, 0, 5, 'O MESMO', 'DEBITO', 201, 11,'EM SEPARACAO');
INSERT INTO pedido VALUES ( pedido_seq.nextval, current_timestamp - 30,'FONE' , 230, 0, 5, 'O MESMO', 'CTCRED', 203, 8,'EM SEPARACAO');
INSERT INTO pedido VALUES ( pedido_seq.nextval, current_timestamp - 20,'FONE' , 2200, 0, 5, 'O MESMO', 'CTCRED', 204,11,'EM SEPARACAO');
INSERT INTO pedido VALUES ( pedido_seq.nextval, current_timestamp - 10,'FONE' , 4200, 0, 5, 'O MESMO', 'CTCRED', 209, 8,'EM SEPARACAO');
INSERT INTO pedido VALUES ( pedido_seq.nextval, current_timestamp - 1,'FONE' , 208, 0, 5, 'O MESMO', 'CTCRED', 210, 9,'EM SEPARACAO');
INSERT INTO pedido VALUES ( pedido_seq.nextval, current_timestamp ,'FONE' , 208, 0, 5, 'O MESMO', 'DIN', 202, 9,'EM SEPARACAO');
INSERT INTO pedido VALUES ( pedido_seq.nextval, current_timestamp ,'FONE' , 208, 0, 5, 'O MESMO', 'DIN', 205, 9,'EM SEPARACAO');

--itens_pedido ;
INSERT INTO itens_pedido VALUES ( 2020,5001,1 , 5);
INSERT INTO itens_pedido VALUES ( 2020, 5002, 2, 15);
INSERT INTO itens_pedido VALUES ( 2020, 5003,3 , 7 );
INSERT INTO itens_pedido VALUES ( 2020, 5004,4 , 5);
INSERT INTO itens_pedido VALUES ( 2020, 5005,4 , 10);
INSERT INTO itens_pedido VALUES ( 2020, 5006,3, 15);
INSERT INTO itens_pedido VALUES ( 2020, 5007,2 , 5);
INSERT INTO itens_pedido VALUES ( 2021, 5001,1 , 3);
INSERT INTO itens_pedido VALUES ( 2021, 5002, 1, 5);
INSERT INTO itens_pedido VALUES ( 2021, 5003,8 , 5);
INSERT INTO itens_pedido VALUES ( 2021, 5004,4 , 5);
INSERT INTO itens_pedido VALUES ( 2021, 5005,2 , 5);
INSERT INTO itens_pedido VALUES ( 2021, 5006,3 , 35);
INSERT INTO itens_pedido VALUES ( 2021, 5007,6, 30);
INSERT INTO itens_pedido VALUES ( 2022, 5001,9 , 5);
INSERT INTO itens_pedido VALUES ( 2022, 5002,11 ,5);
INSERT INTO itens_pedido VALUES ( 2023, 5001,1 , 15);
INSERT INTO itens_pedido VALUES ( 2023, 5002,3, 11);
INSERT INTO itens_pedido VALUES ( 2024, 5001,7, 6);
INSERT INTO itens_pedido VALUES ( 2024, 5002,9 , 30);
INSERT INTO itens_pedido VALUES ( 2024, 5003,15 , 12);
INSERT INTO itens_pedido VALUES ( 2024, 5004,20 , 19);
INSERT INTO itens_pedido VALUES ( 2025, 5001,30, 16);
INSERT INTO itens_pedido VALUES ( 2025, 5003,30 , 22);
INSERT INTO itens_pedido VALUES ( 2025, 5002, 10, 12);
INSERT INTO itens_pedido VALUES ( 2026, 5001,15 , 16);
INSERT INTO itens_pedido VALUES ( 2026, 5002,24 , 15);
INSERT INTO itens_pedido VALUES ( 2026, 5003,12 , 18);
INSERT INTO itens_pedido VALUES ( 2026, 5004,6 , 27);
INSERT INTO itens_pedido VALUES ( 2026, 5006,6, 5);
INSERT INTO itens_pedido VALUES ( 2026, 5005, 3, 12);
INSERT INTO itens_pedido VALUES ( 2027, 5010, 2, 5);
INSERT INTO itens_pedido VALUES ( 2027, 5002, 1, 11);
INSERT INTO itens_pedido VALUES ( 2027, 5003, 16, 5);
INSERT INTO itens_pedido VALUES ( 2027, 5004, 9, 5);
INSERT INTO itens_pedido VALUES ( 2027, 5005, 8, 0);
INSERT INTO itens_pedido VALUES ( 2028, 5001, 9, 0);
INSERT INTO itens_pedido VALUES ( 2028, 5006, 35, 50);
INSERT INTO itens_pedido VALUES ( 2028, 5007, 5, 0);
INSERT INTO itens_pedido VALUES ( 2028, 5005, 10, 0);
INSERT INTO itens_pedido VALUES ( 2028, 5002, 8, 0);
INSERT INTO itens_pedido VALUES ( 2028, 5004, 7, 0);
INSERT INTO itens_pedido VALUES ( 2028, 5003, 9,10);
INSERT INTO itens_pedido VALUES ( 2029, 5011, 5, 20);
INSERT INTO itens_pedido VALUES ( 2029, 5005, 5,30);
INSERT INTO itens_pedido VALUES ( 2029, 5007, 5, 10);
INSERT INTO itens_pedido VALUES ( 2029, 5006, 4, 0);
INSERT INTO itens_pedido VALUES ( 2029, 5004, 12, 30);
INSERT INTO itens_pedido VALUES ( 2029, 5002, 5, 20);
INSERT INTO itens_pedido VALUES ( 2029, 5003, 5, 15);
INSERT INTO itens_pedido VALUES ( 2030, 5011, 9, 10);
INSERT INTO itens_pedido VALUES ( 2030, 5002, 1, 0);

INSERT INTO itens_pedido VALUES ( 2031, 5021, 5, 20);
INSERT INTO itens_pedido VALUES ( 2031, 5015, 5,30);
INSERT INTO itens_pedido VALUES ( 2031, 5017, 5, 10);
INSERT INTO itens_pedido VALUES ( 2031, 5016, 4, 0);
INSERT INTO itens_pedido VALUES ( 2031, 5014, 12, 30);
INSERT INTO itens_pedido VALUES ( 2031, 5012, 5, 20);
INSERT INTO itens_pedido VALUES ( 2032, 5013, 5, 15);
INSERT INTO itens_pedido VALUES ( 2032, 5021, 9, 10);
INSERT INTO itens_pedido VALUES ( 2032, 5019, 1, 0);

INSERT INTO itens_pedido VALUES ( 2033,5026,1 , 5);
INSERT INTO itens_pedido VALUES ( 2033, 5022, 2, 15);
INSERT INTO itens_pedido VALUES ( 2033, 5003,3 , 7 );
INSERT INTO itens_pedido VALUES ( 2033, 5024,4 , 5);
INSERT INTO itens_pedido VALUES ( 2033, 5005,4 , 10);
INSERT INTO itens_pedido VALUES ( 2033, 5006,3, 15);
INSERT INTO itens_pedido VALUES ( 2033, 5017,2 , 5);
INSERT INTO itens_pedido VALUES ( 2034, 5026,1 , 3);
INSERT INTO itens_pedido VALUES ( 2034, 5002, 1, 5);
INSERT INTO itens_pedido VALUES ( 2034, 5013,8 , 5);
INSERT INTO itens_pedido VALUES ( 2034, 5024,4 , 5);
INSERT INTO itens_pedido VALUES ( 2034, 5005,2 , 5);
INSERT INTO itens_pedido VALUES ( 2034, 5016,3 , 35);
INSERT INTO itens_pedido VALUES ( 2034, 5007,6, 30);


ALTER TABLE itens_pedido ADD ( preco_item NUMBER(10,2), total_item NUMBER(10,2) ) ;
UPDATE itens_pedido i SET i.preco_item = ( SELECT p.preco_venda*0.995 FROM produto p
WHERE p.cod_prod = i.cod_prod ) ;

-- atualizando o total dos pedidos
UPDATE pedido ped
SET ped.vl_total_ped =
(SELECT sum(i.qtde_pedida*i.preco_item*(100-i.descto_item)/100)
FROM itens_pedido i, produto p
WHERE ped.num_ped = i.num_ped
AND i.cod_prod = p.cod_prod );

COMMIT ;
-- contagem de linhas para cada tabela
SELECT count(*) AS Itens FROM itens_pedido ;
SELECT count(*) AS Regiao FROM regiao ;
SELECT count(*) AS Produto FROM produto ;
SELECT count(*) AS Cliente FROM cliente ;
SELECT count(*) AS Pedido FROM pedido ;
SELECT count(*) AS Armazenamento FROM armazenamento ;
SELECT count(*) AS Funcionario FROM funcionario ;
SELECT count(*) AS Depto  FROM departamento ;
SELECT count(*) AS Cargo FROM cargo ;

-- todos os clientes
select cod_cli_pf as Cod, nome_fantasia AS NOME from cliente_pf
union
select cod_cli_pj as Cod, razao_social_cli AS Nome from cliente_pj ;

-- alteracao na estrutura de itens pedido
ALTER TABLE itens_pedido ADD situacao_item CHAR(15)
CHECK ( situacao_item IN ( 'SEPARACAO', 'ENTREGUE', 'CANCELADO', 'DESPACHADO')) ;
UPDATE itens_pedido SET situacao_item = 'SEPARACAO' ;

/******************************************************************************************************************/

-- Programacao BD Vendas Produtos Esportivos
/*
cliente ( cod_cli(PK), limite_credito, endereco_cli, fone_cli, situacao_cli, tipo_cli, cod_regiao(fk),pais_cli, nome_fantasia)
cliente_pf (cod_cli_pf(PK)(FK), nome_fantasia, cpf_cli, sexo_cli, profissao_cli)
cliente_pj (cod_cli_pj(PK)(FK), razao_social_cli, cnpj_cli, ramo_atividade_cli)
produto ( cod_prod(PK), nome_prod, descr_prod, categ_esporte(FK), preco_venda, preco_custo, peso, marca(FK), tamanho)
funcionario ( cod_func(PK), nome_func, end_func, cod_depto, sexo_func, dt_admissao, cod_cargo(FK), cod_regiao(fk), cod_func_gerente(FK),
pais_func, salario)
departamento(cod_depto(PK), nome_depto, cod_regiao(FK))
regiao (cod_regiao(PK), nome_regiao)
deposito ( cod_depo(PK), nome_depo, end_depo, cidade_depo, pais_depo, cod_regiao(fk), cod_func_gerente_depo(FK))
pedido ( num_ped(PK), dt_hora_ped, tp_atendimento, vl_total_ped, vl_descto_ped, vl_frete_ped,
 end_entrega, forma_pgto(FK), cod_cli(fk), cod_func_vendedor(fk), situacao_ped)
itens_pedido (num_ped(FK)(PK), cod_prod(fk)(PK), qtde_pedida, descto_item, preco_item, total_item, situacao_item)
forma_pgto (cod_forma(PK), descr_forma_pgto)
armazenamento ( cod_depo(FK)(PK), cod_prod(FK)(PK), qtde_estoque, end_estoque)
marca ( sigla_marca(PK), nome_marca, pais_marca)
pais ( sigla_pais(PK), nome_pais) */

/* parametros de configuracao da sessao */
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS';
ALTER SESSION SET NLS_LANGUAGE = PORTUGUESE;
SELECT SESSIONTIMEZONE, CURRENT_TIMESTAMP FROM DUAL;

-- TRIGGERS
-- Gatilho para validar a inserção na tabela cliente PF
CREATE OR REPLACE TRIGGER valida_pf
-- gatilhos não possuem parâmentros e retornam apenas mensagens de erro
-- gatilho dispara antes da ação do usuario
BEFORE INSERT OR UPDATE ON cliente_pf FOR EACH ROW
DECLARE --todo trigger necessita de um declare
vtipocli cliente.tipo_cli%TYPE; --variável ancorada em tipo de dado - não perde referência em alter table
BEGIN
SELECT c.tipo_cli INTO vtipocli FROM cliente c WHERE c.cod_cli = :NEW.cod_cli_pf;
--validação
IF vtipocli != 'PF' THEN
--código de erro
  RAISE_APPLICATION_ERROR (-20001, 'Cliente' || TO_CHAR(:NEW.cod_cli_pf) || 'nao corresponde a pessoa fisica');
END IF;
END;

SELECT * FROM cliente WHERE tipo_cli = 'PF';

-- testando o gatilho
INSERT INTO cliente_pf VALUES (201, 'teste', 123, 'M', 'teste');
UPDATE cliente_pf SET cod_cli_pf = 202 WHERE cod_cli_pf = 200; --200 corresponde a um cliente PJ

-- Gatilho para validar a inserção na tabela cliente PJ
CREATE OR REPLACE TRIGGER valida_pj
-- gatilhos não possuem parâmentros e retornam apenas mensagens de erro
-- gatilho dispara antes da ação do usuario
BEFORE INSERT OR UPDATE ON cliente_pj FOR EACH ROW
DECLARE --todo trigger necessita de um declare
vtipocli cliente.tipo_cli%TYPE; --variável ancorada em tipo de dado - não perde referência em alter table
BEGIN
SELECT c.tipo_cli INTO vtipocli FROM cliente c WHERE c.cod_cli = :NEW.cod_cli_pj;
--validação
IF vtipocli != 'PJ' THEN
--código de erro
  RAISE_APPLICATION_ERROR (-20002, 'Cliente' || TO_CHAR(:NEW.cod_cli_pj) || 'nao corresponde a pessoa juridica');
END IF;
END;

SELECT * FROM cliente WHERE tipo_cli = 'PF';

-- testando o gatilho
INSERT INTO cliente_pj VALUES (210, 'teste', 123, 'teste');

--uso do gatilho AFTER, cria logs de operações personalizadas
--controle de auditoria na tabela PRODUTO
DROP TABLE auditoria_produto CASCADE CONSTRAINTS;
CREATE TABLE auditoria_produto
  (num_log INTEGER PRIMARY KEY,
  acao CHAR(15) NOT NULL CHECK (acao IN ('inclusao', 'atualizacao', 'exclusao')),
  dt_hora_operacao TIMESTAMP NOT NULL,
  usuario VARCHAR(32) NOT NULL,
  codprod_antes INTEGER,
  codprod_depois INTEGER,
  preco_vda_antes NUMBER (10,2),
  preco_vda_depois NUMBER (10,2));

CREATE SEQUENCE log_produto;
--gatilho para registrar alterações em produto
CREATE OR REPLACE TRIGGER gera_log_produto
AFTER INSERT OR UPDATE OR DELETE ON produto
FOR EACH ROW
BEGIN
--verificando a alteração feita pelo usuário por meio das variáveis de sessão
IF INSERTING THEN
  INSERT INTO auditoria_produto VALUES (log_produto.nextval, 'inclusao', current_timestamp, user,
  null, :NEW.cod_prod, null, :NEW.preco_venda);
ELSIF UPDATING THEN
  INSERT INTO auditoria_produto VALUES (log_produto.nextval, 'atualizacao', current_timestamp, user,
  :OLD.cod_prod, :NEW.cod_prod, :OLD.preco_venda, :NEW.preco_venda);
ELSIF DELETING THEN
  INSERT INTO auditoria_produto VALUES (log_produto.nextval, 'exclusao', current_timestamp, user,
  :OLD.cod_prod, null, :OLD.preco_venda, null);
END IF;
END;
--testando
INSERT INTO produto VALUES (produto_seq.nextval, 'Bola NBA LeBron', 'Bola NBA LeBron', 'BASQ', 72,  65.75, 300, 'NIK', 'u');
UPDATE produto SET cod_prod = 9999, preco_venda = 99 WHERE cod_prod = 5027;
DELETE produto WHERE cod_prod = 9999;

--controle para validar se o funcionario no pedido é de fato um vendedor
SELECT * FROM cargo;
SELECT nome_func, cod_cargo FROM funcionario;

CREATE OR REPLACE TRIGGER valida_vendedor_pedido
BEFORE INSERT OR UPDATE ON pedido
FOR EACH ROW
--variável que captura o código do funcionario
DECLARE
vcargo cargo.nome_cargo%TYPE;
BEGIN
SELECT c.nome_cargo INTO vcargo
FROM cargo c JOIN funcionario f ON (c.cod_cargo = f.cod_cargo)
WHERE f.cod_func = :NEW.cod_func_vendedor;
IF UPPER(vcargo) NOT LIKE '%VENDEDOR%' THEN
  RAISE_APPLICATION_ERROR (20003, 'Funcionario' || TO_CHAR(:NEW.cod_func_vendedor) || 'nao e vendedor');
END IF;
END;
--testando
INSERT INTO pedido VALUES (pedido_seq.nextval, current_timestamp, 'FONE', 208, 0, 5, 'O MESMO', 'DIN', 205, 4, 'EM SEPARACAO');


/**********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************
***********************************************************************************************************/

--EXERCICIOS LOTE 01

/****************************************************************************************************
1. Escreva as instruções PL/SQL para implementar o seguintes controles:
- Validar a inserção ou atualização na tabela funcionário garantindo que a data de admissão é sempre maior ou igual á data atual
******************************************************************************************************/
DROP TRIGGER valida_data_admissao ;
CREATE OR REPLACE TRIGGER valida_data_admissao
BEFORE INSERT OR UPDATE ON funcionario
FOR EACH ROW
BEGIN
IF :NEW.dt_admissao < current_date THEN
  RAISE_APPLICATION_ERROR (-20003, ' Data de admissao deve ser maior ou igual a data atual !!');
END IF;
END ;

select * from funcionario ;
-- teste
UPDATE funcionario set dt_admissao = current_date - 30
WHERE cod_func = 1 ;

ALTER TRIGGER valida_admissao ENABLE ;

--2. Evitar que o valor do desconto de um pedido seja superior a 20% do valor do pedido
CREATE OR REPLACE TRIGGER limita_desconto
BEFORE INSERT OR UPDATE OF vl_descto_ped ON pedido
FOR EACH ROW
BEGIN
IF :NEW.vl_descto_ped > (:NEW.vl_total_ped*20)/100 THEN
    RAISE_APPLICATION_ERROR ( -20004, 'Valor do desconto ultrapassa 20% do valor do pedido! Aplique um desconto menor.');
END IF ;
END ;
-- teste
SELECT num_ped, vl_total_ped, vl_descto_ped FROM pedido ;
UPDATE pedido SET vl_descto_ped = 319.00
WHERE num_ped = 2021 ;

--3. Registrar em log a inclus?o e atualiza??o de itens no pedido. Por exemplo, se alterar a quantidade pedida, cancelar o item, etc.
--Nãoo haverá exclusão de item.
--Tabela para registrar o log
DROP TABLE auditoria_item CASCADE CONSTRAINTS;
CREATE TABLE auditoria_item
( id_log INTEGER PRIMARY KEY,
  acao CHAR(20) CHECK (acao IN ('INSERCAO','EXCLUSAO','ATUALIZA PRECO',
  'ATUALIZA DESCONTO', 'ATUALIZA SITUACAO')) NOT NULL,
  usuario VARCHAR2(30) NOT NULL,
  data_hora_operacao TIMESTAMP NOT NULL,
  produto INTEGER,
  pedido INTEGER,
  old_preco NUMBER(10,2),
  new_preco NUMBER(10,2),
  old_desconto NUMBER(10,2),
  new_desconto NUMBER(10,2),
  old_situacao VARCHAR2(20),
  new_situacao VARCHAR2(20) );

DROP SEQUENCE log_item ;
CREATE sequence log_item start with 1000 ;

/*****************************************************************************************
 gatilho para registrar operações em item
*****************************************************************************************/
DROP TRIGGER gera_log_item ;
CREATE OR REPLACE TRIGGER gera_log_item
AFTER UPDATE OR INSERT ON itens_pedido
FOR EACH ROW
BEGIN
 IF INSERTING THEN
    INSERT INTO auditoria_item VALUES ( log_item.nextval, 'INSERCAO', USER, current_timestamp,
      :NEW.cod_prod , :NEW.num_ped, null, :NEW.preco_item, null, :NEW.descto_item,
      null, :NEW.situacao_item);
ELSIF UPDATING ('preco_item') THEN
   INSERT INTO auditoria_item VALUES ( log_item.nextval, 'ATUALIZA PRECO', USER, current_timestamp,
      :OLD.cod_prod , :OLD.num_ped, :OLD.preco_item, :NEW.preco_item, null, null, null, null);
ELSIF UPDATING('descto_item') THEN
   INSERT INTO auditoria_item VALUES ( log_item.nextval, 'ATUALIZA DESCONTO', USER, current_timestamp,
      :OLD.cod_prod , :OLD.num_ped, null, null, :OLD.descto_item, :NEW.descto_item,
      null, null);
ELSIF UPDATING('situacao_item') THEN
   INSERT INTO auditoria_item VALUES ( log_item.nextval, 'ATUALIZA SITUACAO', USER, current_timestamp,
      :OLD.cod_prod , :OLD.num_ped, null, null, null,null,
      :OLD.situacao_item, :NEW.situacao_item);
END IF;
END gera_log_item ;

-- testes
SELECT * FROM auditoria_item ;
DESCR itens_pedido ;
SELECT * FROM pedido ;
SELECT * from itens_pedido where NUM_PED = 2020;
-- insercao
INSERT INTO itens_pedido VALUES ( 2020, 5011, 11 , 5, 99, 0, 'SEPARACAO');
-- atualiza preco
UPDATE itens_pedido SET preco_item = 100.99
WHERE num_ped = 2020 AND cod_prod = 5011 ;
-- atualiza desconto
UPDATE itens_pedido SET descto_item = 5.55
WHERE num_ped = 2020 AND cod_prod = 5011 ;
-- atualiza situacao
UPDATE itens_pedido SET situacao_item = 'CANCELADO'
WHERE num_ped = 2020 AND cod_prod = 5011 ;

-- TRIGGERS

/***************************************************************
Controle para evitar que o preço do item de um produto -
ao ser inserido ou atualizado- seja maior que o preço de venda do produto.*/
SELECT * FROM produto;
SELECT * FROM itens_pedido;

UPDATE itens_pedido i SET i.preco_item =
  --*0.995 está aplicando um micro-desconto de 0,5%
  (SELECT p.preco_venda*0.995 FROM produto p WHERE i.cod_prod = p.cod_prod);
ALTER TABLE itens_pedido DISABLE ALL TRIGGERS;
--gatilho para validação do preço
CREATE OR REPLACE TRIGGER valida_preco_item
BEFORE INSERT OR UPDATE ON itens_pedido
FOR EACH ROW
DECLARE
vpreco produto.preco_venda%TYPE;
--tratando a transação de forma isolada (diretiva de compiplação)
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
--capturar o preco de venda do item que estamos manipulando
SELECT get_preco_venda (:NEW.cod_prod) INTO vpreco FROM dual;
--comparando os precos
IF :NEW.preco_item > vpreco OR :NEW.preco_item <=0 THEN
  RAISE_APPLICATION_ERROR (-20005, 'Preco do item nao pode ser superior ao preco de venda, nem ser de graca');
END IF;
END;

--testando gatilho
SELECT * FROM pedido;
SELECT get_preco_venda (5002) FROM dual;
UPDATE itens_pedido SET preco_item = 200 WHERE num_ped = 2020 AND cod_prod = 5002;
INSERT INTO itens_pedido VALUES (2034, 5003, 1, 30, 57, 0, 'SEPARACAO');

--FUNÇÃO
--Função que retorna o preço de venda do produto, passando o código
--Toda função deve ter obirgatóriamente um retorno
CREATE OR REPLACE FUNCTION get_preco_venda (vcodigo In produto.cod_prod%TYPE)
RETURN NUMBER IS
vpreco produto.preco_venda%TYPE;
BEGIN
SELECT p.preco_venda INTO vpreco FROM produto p WHERE p.cod_prod = vcodigo;
RETURN vcodigo;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20006, 'Produto' || TO_CHAR(vcodigo) || 'nao foi localizado');
END;

SELECT get_preco_venda (10031) FROM dual;

/*********************************************************************************
Validar a inserção de um produto como item desde que a quantidade pedida
seja menor ou igual á quantidade em estoque para o depósito que atende á região do cliente, ou seja,
não será possível cadastrar um item no pedido se não houver quantidade suficiente no estoque.*/
CREATE OR REPLACE TRIGGER valida_estoque
BEFORE INSERT OR UPDATE ON itens_pedido
FOR EACH ROW
DECLARE
vdepo deposito.cod_depo%TYPE ;
vqtde_estq armazenamento.qtde_estoque%TYPE ;
BEGIN
-- capturar o deposito do cliente
SELECT d.cod_depo INTO vdepo
FROM deposito d JOIN cliente c ON ( d.cod_regiao = c.cod_regiao)
  JOIN pedido p ON ( p.cod_cli = c.cod_cli)
WHERE p.num_ped = :NEW.num_ped ;
-- capturar a qtde em estoque para o item de produto que esta pedindo
SELECT NVL(a.qtde_estoque,0) INTO vqtde_estq
FROM armazenamento a
WHERE a.cod_depo = vdepo
    AND a.cod_prod = :NEW.cod_prod ;
-- validacao para verificar se a qtde em estoque atende a qtde pedida no item
IF :NEW.qtde_pedida > vqtde_estq THEN
    RAISE_APPLICATION_ERROR ( -20007, 'Produto '||TO_CHAR(:NEW.cod_prod)||' nao tem estoque suficiente !!! Falta(m) '||
      TO_CHAR ( :NEW.qtde_pedida - vqtde_estq) ||' unidades ') ;
END IF ;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RAISE_APPLICATION_ERROR ( -20008, 'Produto '||TO_CHAR(:NEW.cod_prod)||' nao localizado no deposito !!!!') ;
END;
-- teste
SELECT * FROM armazenamento;
INSERT INTO armazenamento VALUES ( 201, 5007, 5, 'A0123');
SELECT * FROM itens_pedido WHERE num_ped = 2034;
SELECT d.cod_depo , p.cod_cli
FROM deposito d JOIN cliente c ON ( d.cod_regiao = c.cod_regiao) JOIN pedido p ON ( p.cod_cli = c.cod_cli)
WHERE p.num_ped = 2034;
UPDATE itens_pedido SET qtde_pedida = 6
WHERE num_ped = 2020 AND cod_prod = 5007;-- funcionou que gerou o erro
-- para um produto que não tem no deposito
INSERT INTO itens_pedido VALUES ( 2034, 5012, 1, 10, 1, 0, 'SEPARACAO');-- funcionou gerou o erro NO_DATA_FOUND

/************************************************************************************************
Controle para evitar que um cliente ultrapasse o seu limite de crédito à medida
que os itens são colocados no pedido. Pense num carrinho de compras e à medida
que os itens são inseridos ou a qtde pedida/preço item/desconto atualizada o limite é verificado.
Faça o tratamento se o item for cancelado.*/

CREATE OR REPLACE TRIGGER testa_limite_credito
BEFORE INSERT OR UPDATE ON itens_pedido
FOR EACH ROW
DECLARE
vlimcred cliente.limite_credito%TYPE;-- limite credito cliente
vatualped pedido.vl_total_ped%TYPE;-- valor total atual do pedido
vitem pedido.vl_total_ped%TYPE;-- valor do item que esta sendo manipulado
vnovototal pedido.vl_total_ped%TYPE;-- valor total final ap?s a manipulacao do item
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
-- capturando o limite de credito de um cliente a partir do pedido
SELECT c.limite_credito INTO vlimcred
FROM pedido p, cliente c
WHERE p.cod_cli = c.cod_cli
AND p.num_ped =  :NEW.num_ped ;
    DBMS_OUTPUT.PUT_LINE ( 'Limite : '||TO_CHAR(vlimcred));
-- calculo do valor total do pedido
SELECT SUM( i.qtde_pedida * i.preco_item * ( 100 - i.descto_item) / 100 ) INTO vatualped
FROM itens_pedido i WHERE i.num_ped = :NEW.num_ped
AND i.situacao_item != 'CANCELADO';
  DBMS_OUTPUT.PUT_LINE ( 'Total Ped Antes : '||TO_CHAR(vatualped));
-- calcular o valor do item sendo manipulado
vitem := :NEW.qtde_pedida * :NEW.preco_item * ( 100 - :NEW.descto_item) / 100 -
  NVL( :OLD.qtde_pedida, 0 ) *NVL ( :OLD.preco_item, 0 ) * ( 100 - NVL (:OLD.descto_item, 0 ) ) / 100;
    DBMS_OUTPUT.PUT_LINE ( 'Vl item : '||TO_CHAR(vitem)) ;
-- validando
IF :NEW.situacao_item = 'CANCELADO' AND :NEW.situacao_item <> :OLD.situacao_item THEN vnovototal := vatualped - vitem ;
  DBMS_OUTPUT.PUT_LINE ( 'Cancelado : '||TO_CHAR(vnovototal));
ELSE
  vnovototal := vatualped + vitem ;
    DBMS_OUTPUT.PUT_LINE ( 'Valendo : '||TO_CHAR(vnovototal));
END IF ;
IF vnovototal > vlimcred THEN
    RAISE_APPLICATION_ERROR ( -20020, 'Este item '||TO_CHAR(:NEW.cod_prod)||' excede o limite de credito !!!') ;
END IF ;
END ;

-- testando
SELECT c.limite_credito, c.cod_cli FROM pedido p, cliente c WHERE p.cod_cli = c.cod_cli
AND p.num_ped =  2025;
UPDATE cliente SET limite_credito = 10500 WHERE cod_cli = 204;
SELECT SUM( i.qtde_pedida * i.preco_item * ( 100 - i.descto_item) / 100)
FROM itens_pedido i
WHERE i.num_ped = 2025
AND i.situacao_item != 'CANCELADO';

-- vendo os itens do 2025
SELECT * FROM itens_pedido WHERE num_ped =  2025;
-- aumentar a qtde de um dos itens
ALTER TABLE itens_pedido DISABLE ALL TRIGGERS;
ALTER TRIGGER testa_limite_credito ENABLE;
COMMIT;

UPDATE itens_pedido SET qtde_pedida = 31 WHERE num_ped = 2025 AND cod_prod = 5001;
UPDATE itens_pedido SET situacao_item = 'CANCELADO' WHERE num_ped = 2025 AND cod_prod = 5001;
UPDATE itens_pedido SET descto_item = 0 WHERE num_ped = 2025 AND cod_prod = 5002;


/**********************************************************************************
Atividade 2 - Escreva as instruções PL/SQL para implementar o seguintes controles:
1-  Validar a região do vendedor que atende o pedido para a mesma região do cliente, ou seja,
não permitir que um vendedor de outra região atenda o cliente;
**********************************************************************************/
CREATE OR REPLACE trigger valida_vendedor_regiao
BEFORE INSERT OR UPDATE ON pedido
FOR EACH ROW
DECLARE
rvendor regiao.cod_regiao%TYPE;
rcliente regiao.cod_regiao%TYPE;
BEGIN --captura a regiao do cliente
SELECT c.cod_regiao INTO rcliente
from cliente c
where c.cod_cli =:NEW.cod_cli; --captura a regiao do vendedor
SELECT f.cod_regiao INTO rvendor
from  funcionario f
where f.cod_func = :NEW.cod_func_vendedor;
-- compara se eh a mesma regiao
IF rcliente <> rvendor THEN
  RAISE_APPLICATION_ERROR (-20004 , 'Vendedor nao pertence à mesma regiao do cliente !!'
    ||'Vendedor : '||TO_CHAR(rvendor)|| ' x  Cliente :'||TO_CHAR(rcliente));
END IF;
END;

-- testando
INSERT INTO pedido VALUES (pedido_seq.nextval, current_timestamp - 100, 'FONE' , 1000, 15, 12, 'o mesmo', 'CTCRED' , 200, 4 , 'APROVADO');

/* 2 - Evitar que o salário de um novo funcionário seja superior ao maior salário para o mesmo cargo.
Por exemplo, José é Vendedor, então o salário de José não pode ser maior que o maior salário que um vendedor tenha atualmente.*/
CREATE OR REPLACE TRIGGER valida_salario_cargo
BEFORE INSERT OR UPDATE ON funcionario
FOR EACH ROW
DECLARE
vmaior_sal funcionario.salario%TYPE;
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  SELECT MAX(f.salario) into vmaior_sal
    FROM funcionario f WHERE f.cod_cargo = :NEW.cod_cargo;
IF :NEW.salario > vmaior_sal THEN
     RAISE_APPLICATION_ERROR  (-20038, 'Salario não pode ultrapassar o teto para o cargo!!.');
END IF ;
END ;
-- testando
SELECT * FROM funcionario;
SELECT * FROM cargo;
SELECT MAX (f.salario) FROM funcionario f WHERE f.cod_cargo = 3;
INSERT INTO funcionario VALUES (20, 'Jacob Stradivarius', '17 Juni Strasse','M', '19-01-2011',3, 14, 6, 6, 'ALE', 5461);  -- ok deu erro

/* 3 - Elabore um controle para evitar que um funcionário que não tenha o cargo de gerente seja cadastrado como gerente de outro funcionário,
ou seja, somente funcionários com cargo de Gerente podem gerenciar outros funcionários, e além disso os gerentes devem ser da mesma região
que o funcionário. */
CREATE OR REPLACE TRIGGER valida_gerente
BEFORE INSERT OR UPDATE ON funcionario
FOR EACH ROW
DECLARE
vcargo cargo.nome_cargo%TYPE;
vregiao regiao.cod_regiao%TYPE;
BEGIN
--captura o nome do cargo e a regiao do funcionario gerente
  SELECT nome_cargo, cod_regiao INTO vcargo, vregiao FROM funcionario f, cargo c
  WHERE f.cod_cargo = c.cod_cargo AND f.cod_func = :NEW.cod_func_gerente;
IF UPPER(vcargo) NOT LIKE '%GERENTE%' THEN
  RAISE_APPLICATION_ERROR ( -20035, 'Empregado gerente não confere com o cargo!!. Ele é '||vcargo);
ELSIF  vregiao <> :NEW.cod_regiao THEN
  RAISE_APPLICATION_ERROR ( -20036, 'Regiao '||TO_CHAR(vregiao)|| 'do gerente é diferente da regiao'
    ||TO_CHAR(:NEW.cod_regiao)||' do  funcionário !');
END IF;
END;
-- testando
DESC funcionario;
INSERT INTO funcionario VALUES (20, 'Jacob Stradivarius', '17 Juni Strasse','M', '19-01-2011', 3 , 14, 6, 2, 'ALE', 5400);
-- gerente 5
SELECT * FROM funcionario;
SELECT * FROM cargo;

/**********************************************************************************
AULA 4 - Triggers e Functions - 17/set/2020
***********************************************************************************/
--uniformizando tabela itens pedido e pedido
ALTER TABLE itens_pedido DISABLE ALL TRIGGERS;
UPDATE itens_pedido SET situacao_item = 'SEPARACAO';
ALTER TABLE pedido DISABLE ALL TRIGGERS;
UPDATE pedido p SET p.vl_total_ped =
  (SELECT SUM (i.qtde_pedida * get_preco_venda (i.cod_prod) * (100 - i.descto_item)/100)
  FROM itens_pedido i WHERE i.num_ped = p.num_ped);

--criango gatilho que atualiza valores de venda conforme os itens sao manipulados
CREATE OR REPLACE TRIGGER atualiza_pedido
AFTER INSERT OR UPDATE OF qtde_pedida, descto_item, situacao_item ON itens_pedido
FOR EACH ROW
DECLARE
vtotalped_antes pedido.vl_total_ped%TYPE;
vtotalped_depois pedido.vl_total_ped%TYPE;
vpreco_prod produto.preco_venda%TYPE;
vpedido pedido.num_ped%TYPE;
--PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
--buscar o preco do produto manipulado no carrinho
SELECT get_preco_venda(:NEW.cod_prod) INTO vpreco_prod FROM dual;
--no caso de insert somar o valor do novo item ao valor total do pedido
IF INSERTING THEN
  SELECT p.vl_total_ped INTO vtotalped FROM pedido p WHERE p.num_ped = :NEW.num_ped;
  vpedido := :NEW.num_ped;
--calculando o valor acrecentrado
vtotalped_depois := vtotalped_antes + (:NEW.qtde_pedida * vpreco_prod * (100 - :NEW.descto_item)/100);
ELSIF UPDATING AND :OLD.situacao_item = 'SEPARACAO' THEN
  SELECT p.vl_total_ped INTO vtotalped_antes FROM pedido p WHERE p.num_ped = :OLD.num_ped;
  vpedido:= :OLD.num_ped;
--cancelamento
IF :NEW.situacao_item = 'CANCELADO' AND :NEW.situacao_item <> :OLD.situacao_item THEN
  vtotalped_depois := vtotalped_antes - (:OLD.qtde_pedida * vpreco_prod * (100 - :OLD.descto_item)/100);
  --mudando apenas a quantidade (desconto fica igual)
  ELSIF :NEW.qtde_pedida <> :OLD.qtde_pedida AND :NEW.descto_item = :OLD.descto_item THEN
  vtotalped_depois := vtotalped_antes +
    ((:NEW.qtde_pedida - :OLD.qtde_pedida) * vpreco_prod * (100 - :OLD.descto_item)/100);
  --mudando apenas o desconto (quantidade fica igual)
  ELSIF :NEW.qtde_pedida = :OLD.qtde_pedida AND :NEW.descto_item <> :OLD.descto_item THEN
    vtotalped_depois := vtotalped_antes = :OLD.qtde_pedida * vpreco_prod * (:OLD.descto_item - :NEW.descto_item)/100;
  --mudando quantidade e desconto
  ELSIF :NEW.qtde_pedida <> :OLD.qtde_pedida AND :NEW.descto_item <> :OLD.descto_item THEN
    vtotalped_depois := vtotalped_antes + (:NEW.qtde_pedida * vpreco_prod * (100 - :NEW.descto_item)/100)
      - (:OLD.qtde_pedida * vpreco_prod * (100 - :OLD.descto_item)/100);
  END IF;
END IF;
--atualizando o valor do pedido
IF vtotal_depois <> vtotal_antes THEN
  UPDATE pedido p SET p.vl_total_ped = vtotalped_depois WHERE p.num_ped = vpedido;
END IF;
END;

-- testando
SELECT * FROM pedido;
SELECT * FROM produto;
SELECT * FROM itens_pedido WHERE num_ped = 2023;
INSERT INTO itens_pedido VALUES (2023, 5023, 10, 0, 105, null, 'SEPARACAO');

/*****************************************************************************************************************/
/* FUNÇÕES */
/* Função que retorna o preço de venda de um produto passando como parâmetro o nome ou parte do nome.
Suponha que o nome do produto é único, não se repete.*/
CREATE OR REPLACE FUNCTION get_preco_nome (vnome IN produto.nome_prod%TYPE)
RETURN NUMBER
IS vpreco produto.preco_venda%TYPE;
vbusca produto.nome_prod%TYPE := '%'||UPPER (vnome)||'%'; --busca por string
vachou SMALLINT := 0;
BEGIN
-- testando se achou, e se achar deve ser somente 1 ou o parâmetro deve ser melhorado
SELECT COUNT (*) INTO vachou FROM produto
WHERE UPPER (nome_prod) LIKE vbusca;
IF vachou = 1 THEN
  SELECT preco_venda INTO vpreco FROM produto WHERE UPPER (nome_prod) LIKE vbusca;
ELSIF achou > 1 THEN
  RAISE_APPLICATION_ERROR (-20010, 'Encontrado mais de um produto com esse nome. Seja mais especifico');
END IF;
RETURN vpreco;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR (-20011, 'Produto nao encontrado');
END;
-- testando erro
SELECT get_preco_nome('bola copa') FROM dual;

/* Função que retorna o valor total vendido, calculado em reais,
para um determinado produto em um período de tempo,
tendo como parâmetros de entrada o código do produto e as datas de início e término do período,
ou seja, quanto o produto vendeu considerando todos os pedidos em que aparece naquele período.
*/

CREATE OR REPLACE FUNCTION vendas_produto (vpro IN produto.cod_prod%TYPE,
vini IN pedido.dt_hora_ped%TYPE, vfim IN pedido.dt_hora_ped%TYPE)
RETURN NUMBER
IS vtotal pedido.vl_total_ped%TYPE;
BEGIN
SELECT SUM (i.qtde_pedida * get_preco_venda(i.cod_prod) * (100 - descto_item)/100) INTO vtotal
FROM itens_pedido i JOIN pedido p ON (i.num_ped = p.num_ped) WHERE i.cod_prod = vprod
AND i.situacao_item <> 'CANCELADO';
RETURN vtotal;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR (-20012, 'Produto nao encontrado');
END;

-- teste
SELECT vendas_produto (5001, current_date - 500, current_date) FROM dual;

/***********************************************************************
usando vetor para retornar mais de um valor : qtde pedida e soma
************************************************************************/

CREATE OR REPLACE TYPE resultado IS VARRAY(5) OF NUMBER;
--usando um vetor de busca com 5 posições
CREATE OR REPLACE FUNCTION vendas_produto_vetor (vpro IN produto.cod_prod%TYPE,
vini IN pedido.dt_hora_ped%TYPE, vfim IN pedido.dt_hora_ped%TYPE)
RETURN resultado
IS vtotal resultado := resultado(); --retornando o valor resultado vazio
BEGIN
vtotal.EXTEND(2); --preenche duas posições no vetor
SELECT SUM (i.qtde_pedida), SUM (i.qtde_pedida * get_preco_venda(i.cod_prod) * (100 - descto_item)/100)
INTO vtotal(1), vtotal(2)
FROM itens_pedido i JOIN pedido p ON (i.num_ped = p.num_ped) WHERE i.cod_prod = vprod
AND i.situacao_item <> 'CANCELADO';
RETURN vtotal;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR (-20012, 'Produto nao encontrado');
END;

-- teste
SELECT vendas_produto_vetor (5001, current_date - 500, current_date) FROM dual;
SELECT vp.* FROM TABLE (vendas_produto_vetor (5011, current_date - 100, current_date)) vp;
SELECT nome FROM (SELECT COLUMN_VALUE AS nome, ROWNUM as linha FROM TABLE (vendas_produto_vetor (5011, current_date - 100, current_date)))
WHERE linha = 2;

/******************************************************************
usando tabela tipada
********************************************************************/
CREATE OR REPLACE TYPE tabresultado IS TABLE OF NUMBER;
--usando um vetor de busca com 5 posições
CREATE OR REPLACE FUNCTION vendas_produto_tab (vpro IN produto.cod_prod%TYPE,
vini IN pedido.dt_hora_ped%TYPE, vfim IN pedido.dt_hora_ped%TYPE)
RETURN tabresultado
IS vtotal tabresultado := tabresultado(null, null); --retornando o valor de uma tabela de números
BEGIN
SELECT SUM (i.qtde_pedida), SUM (i.qtde_pedida * get_preco_venda(i.cod_prod) * (100 - descto_item)/100)
INTO vtotal(1), vtotal(2)
FROM itens_pedido i JOIN pedido p ON (i.num_ped = p.num_ped) WHERE i.cod_prod = vprod
AND i.situacao_item <> 'CANCELADO';
AND p.dt_hora_ped BETWEEN vini AND vfim
AND i.situacao_item <> 'CANCELADO';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR (-20012, 'Produto nao encontrado');
END;

-- teste
SELECT vendas_produto_tab (5001, current_date - 500, current_date) FROM dual;

/**********************
Atividade 3
***********************/
/* 1-Elabore uma função que retorne a quantidade e a soma do valor total dos pedidos feitos por um cliente
 passando como parâmetro o nome ou parte do nome, em um intervalo de tempo. */
CREATE OR REPLACE TYPE resultado_cli AS VARRAY(5) OF NUMBER ;
CREATE OR REPLACE FUNCTION qtde_pedidos ( vcli IN cliente.nome_fantasia%TYPE ,
vini IN pedido.dt_hora_ped%TYPE, vfim IN pedido.dt_hora_ped%TYPE)
RETURN resultado_cli
IS vqtde resultado_cli := resultado_cli() ;
vargumento cliente.nome_fantasia%TYPE := '%'||UPPER(vcli)||'%' ;
vsetem SMALLINT := 0 ;
BEGIN
vqtde.EXTEND(2) ;
     SELECT COUNT(*) INTO vsetem
      FROM cliente
        WHERE upper(nome_fantasia) LIKE vargumento ;
IF vsetem = 1 THEN
                   SELECT COUNT(*), SUM(p.vl_total_ped)  INTO vqtde(1), vqtde(2)
                   FROM pedido p, cliente c
                   WHERE p.cod_cli = c.cod_cli
                   AND UPPER(nome_fantasia) LIKE vargumento
                   AND p.dt_hora_ped BETWEEN vini AND vfim ;
ELSIF vsetem > 1 THEN
           RAISE_APPLICATION_ERROR ( -20011, 'Existe mais de um cliente com este nome. Seja mais específico!');
ELSIF vsetem = 0 THEN
           RAISE_APPLICATION_ERROR ( -20012, 'Cliente não encontrado !!!') ;
END IF ;
RETURN vqtde ;
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
           RAISE_APPLICATION_ERROR ( -20029, 'Cliente não encontrado');
END ;

SELECT * FROM cliente ;
SELECT qtde_pedidos('hamses', current_date - 1000, current_date) FROM DUAL;


/* 2 - Elabore uma função que retorne o valor total vendido, calculado em reais,
para um determinado Gerente de uma equipe de vendas em um período de tempo,
tendo como parâmetros de entrada o código do gerente e as datas de início e término do período,
 ou seja, quanto foi vendido pelos vendedores que são gerenciados por este gerente.
 Considere que na tabela de cargo existe o cargo Gerente Vendas. Faça as validações necessárias.*/

CREATE OR REPLACE FUNCTION total_gerente_vendas ( vgerente IN funcionario.cod_func%TYPE,
                                                 vini IN pedido.dt_hora_ped%TYPE, vfim IN pedido.dt_hora_ped%TYPE)
RETURN NUMBER IS
vtotal pedido.vl_total_ped%TYPE  := 0 ;
vsegerente cargo.nome_cargo%TYPE ;
BEGIN
     SELECT c.nome_cargo INTO vsegerente
      FROM funcionario f, cargo c
        WHERE f.cod_cargo = c.cod_cargo
          AND f.cod_func = vgerente ;
-- testa se eh gerente
IF UPPER (vsegerente) NOT LIKE '%GERENTE DE VENDAS%'  THEN
       RAISE_APPLICATION_ERROR ( -20001, ' Funcionario não é gerente de Vendas !!' );
ELSE
       SELECT SUM(p.vl_total_ped) INTO vtotal
       FROM pedido p, funcionario f
       WHERE p.cod_func_vendedor = f.cod_func
       AND f.cod_func_gerente = vgerente
       AND p.dt_hora_ped BETWEEN vini AND vfim ;
END IF;
RETURN vtotal ;
END ;

-- testando
SELECT * FROM cargo ;  -- 9
SELECT * FROM funcionario WHERE cod_cargo = 9 ;
SELECT total_gerente_vendas (11, current_timestamp - 500, current_timestamp) FROM dual ;
ALTER TABLE funcionario DISABLE ALL TRIGGERS ;
UPDATE funcionario SET cod_cargo = 9 WHERE cod_func = 11 ;
UPDATE funcionario SET cod_func_gerente = null  WHERE cod_func = 11 ;
UPDATE funcionario SET cod_func_gerente = 11 WHERE cod_cargo =2 AND pais_func = 'BRA' ;

/* 3 - Elabore uma função que retorne o valor calculado, em reais,
da comissão de um vendedor para um determinado período de tempo,
 tendo como parâmetros de entrada o código do vendedor, as datas de início e término do período,
 e o percentual de comissão (esse dado não tem o banco), ou seja,
 o total das comissões baseado nos pedidos de um período de tempo.
 Faça as seguintes validações :
 i) comissão não pode ser negativa nem passar de 100% ;
 ii) data final maior ou igual à data inicial do período e não podem ser nulas
 (se forem nulas considere a data final como a data atual e a data inicial 1 mês atrás – comissão dos últimos 30 dias) ;
 iii) se o código do vendedor é de um vendedor mesmo. */

CREATE OR REPLACE FUNCTION comissao_vendedor ( vvendor IN pedido.cod_func_vendedor%TYPE,
                                               vini IN pedido.dt_hora_ped%TYPE,
                                               vfim IN pedido.dt_hora_ped%TYPE,
                                               vcomissao IN NUMBER)
RETURN NUMBER IS
vtotal_comissao pedido.vl_total_ped%TYPE ;
vcargo cargo.nome_cargo%TYPE ;
vinicial pedido.dt_hora_ped%TYPE ;
vfinal pedido.dt_hora_ped%TYPE ;
BEGIN
-- validando a faixa de valores do percentual de comissao
IF vcomissao IS NULL OR vcomissao NOT BETWEEN 0 AND 100 THEN
    RAISE_APPLICATION_ERROR ( -20100, 'Percentual da comissão é obrigatório e deve estar entre 0 e 100!');
END IF ;
-- validando as datas
-- tratar para colocar intervalo de um mês
IF vfim IS NULL OR vini IS NULL THEN
    vinicial := current_date - 30 ;
    vfinal := current_date ;
ELSIF vini IS NOT NULL AND vfim IS NOT NULL THEN
     IF vfim < vini THEN
        RAISE_APPLICATION_ERROR ( -20104, 'Datas são obrigatórias e data final deve ser maior que a inicial!');
     END IF ;
vinicial := vini ;   vfinal := vfim ;
END IF ;
-- validando se o funcionário é vendedor mesmo
SELECT UPPER(c.nome_cargo) INTO vcargo
    FROM cargo c JOIN funcionario f
    ON ( c.cod_cargo = f.cod_cargo)
     WHERE f.cod_func = vvendor ;
IF vcargo NOT LIKE '%VENDE%' THEN
     RAISE_APPLICATION_ERROR ( -20101, 'Funcionário '||TO_CHAR(vvendor)||' é '||vcargo) ;
END IF ;
-- cálculo da comissão
SELECT SUM ( p.vl_total_ped * vcomissao) / 100 INTO vtotal_comissao
FROM pedido p
WHERE p.cod_func_vendedor = vvendor
AND p.dt_hora_ped BETWEEN vinicial AND vfinal ;
RETURN NVL(vtotal_comissao,0) ;
EXCEPTION
WHEN NO_DATA_FOUND THEN
RAISE_APPLICATION_ERROR ( -20102, 'Dados não encontrados !') ;
END ;

-- testando
SELECT comissao_vendedor ( 9 , current_date - 500  , current_date , 10 ) FROM dual ;
SELECT cod_func_vendedor FROM pedido ;
