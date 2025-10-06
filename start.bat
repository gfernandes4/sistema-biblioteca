@echo off
echo "Entrando no diretorio do backend..."
cd projeto-biblioteca-backend

echo "Criando ambiente virtual..."
python -m venv venv

echo "Ativando ambiente virtual e instalando dependencias..."
call .\\venv\\Scripts\\activate.bat
pip install -r requirements.txt

echo "Iniciando o servidor Flask..."
set FLASK_APP=run.py
flask run
