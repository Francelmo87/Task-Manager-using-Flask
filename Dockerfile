# ==========================================
# 🐋 DOCKERFILE CONFIGURADO PARA DEVSECOPS
# ==========================================

# 1. Utiliza uma imagem oficial, estável e leve do Python
FROM python:3.11-slim

# 2. Define variáveis de ambiente essenciais para containers Python
# PYTHONDONTWRITEBYTECODE: Impede que o Python gaste espaço gravando arquivos .pyc
# PYTHONUNBUFFERED: Força os logs a saírem em tempo real diretamente no terminal do Docker
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 3. Define o diretório de trabalho padrão dentro do container
WORKDIR /app

# 4. Instala dependências de compilação necessárias pelo sistema operacional e limpa o cache
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 5. Copia e instala as dependências Python (Executado de forma isolada dentro do Docker)
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# 6. Instala o Gunicorn (Servidor WSGI robusto de produção para o Flask)
RUN pip install --no-cache-dir gunicorn

# 7. Copia todo o restante do código fonte clonado do seu repositório para o container
COPY . /app/

# 8. MITIGAÇÃO DE RISCO (DevSecOps): Cria um usuário sem privilégios administrativos.
# Isso impede ataques de 'Container Escape' (onde o invasor ganha controle da máquina real se o app rodar como root)
RUN useradd -m devsecuser && chown -R devsecuser:devsecuser /app
USER devsecuser

# 9. Informa a porta que o container vai expor para o mundo externo
EXPOSE 5000

# 10. Como o run.py original fica na subpasta todo_project, apontamos a execução para lá
WORKDIR /app/todo_project

# 11. Comando para iniciar o servidor web Gunicorn chamando a instância do app Flask do run.py
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "run:app"]
