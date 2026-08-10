
# DEFINE O AMBIENTE VIRTUAL
VENV_DIR=.venv

# DEFINE DIRETIRIOS
ENGINNERING_DIR=src/engeneering
ANALYTICS_DIR=src/analytics

.PYONY: run setup predict

predict:
	cd src/analytics && ..\..\.venv\Scripts\python.exe predict_fiel.py

# CONFIGURA O AMBIENTE VIRTUAL

# 	rm -rf $(VENV_DIR)
# 	@echo "Configurando o ambiente virtual..."
# 	python -m venv $(VENV_DIR)
# 	$(VENV_DIR)/Scripts/python -m pip install --upgrade pip
# 	$(VENV_DIR)/Scripts/python -m pip install -r requirements.txt
# 	echo "Ambiente virtual configurado com sucesso!"
setup:
	@if exist venv rmdir /s /q venv
	@echo Configurando o ambiente virtual...
	python -m venv venv
	.\venv\Scripts\python.exe -m pip install --upgrade pip
	.\venv\Scripts\python.exe -m pip install -r requirements.txt
	@echo Ambiente virtual configurado com sucesso!



# EXECUTA O SCRIPT DE ENGENHARIA DE DADOS
run:
	@echo "Executando os atualizacoes..."
	.venv\Scripts\python.exe src/engeneering/get_data.py
	cd src/analytics && ..\..\.venv\Scripts\python.exe pipeline_analytics.py

all: setup run predict
