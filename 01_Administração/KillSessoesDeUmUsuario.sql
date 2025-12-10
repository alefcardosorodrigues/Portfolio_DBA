-- Mata todos os processos de um BD de um usuario

USE master

Declare @BD varchar(max)
SET @BD = 'NomeDoDB'

IF @BD = '' 
 BEGIN print ''
  RAISERROR ('Nome do Banco em branco',
               16, -- Severity.
               1 -- State.
               );
 END

Declare @Id int 
Declare a_bc Cursor for 

Select spid 
From sysprocesses 
Where dbid = (Select dbid From sysdatabases Where name = @BD) 

Open a_bc 
Fetch next From a_bc Into @Id

While (@@Fetch_Status = 0) 
Begin 
	-- exec ('kill ' + @Id) Descomentar para funcionar 
	print ('kill ' + convert(varchar, @Id))
	Fetch next From a_bc Into @Id
End 

Close a_bc 
DealLocate a_bc