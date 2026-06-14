from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager
from flask_bcrypt import Bcrypt
from flask_wtf.csrf import CSRFProtect

app = Flask(__name__)
app.config['SECRET_KEY'] = '45cf93c4d41348cd9980674ade9a7356'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///site.db'

# Adiciona configurações de cookies seguros para mitigar o alerta SameSite do ZAP
app.config['REMEMBER_COOKIE_SAMESITE'] = 'Lax'
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'

db = SQLAlchemy(app)
csrf = CSRFProtect(app)

login_manager = LoginManager(app)
login_manager.login_view = 'login' 
login_manager.login_message_category = 'danger'

bcrypt = Bcrypt(app)

# BLINDAGEM COMPLETA DOS ALERTAS HTTP DO OWASP ZAP
@app.after_request
def add_security_headers(response):
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    # Mitiga o alerta de CSP do ZAP permitindo apenas scripts locais (self)
    response.headers['Content-Security-Policy'] = "default-src 'self'; style-src 'self' 'unsafe-inline';"
    # Mitiga o alerta de Permissions Policy do ZAP desligando recursos invasivos
    response.headers['Permissions-Policy'] = "geolocation=(), camera=(), microphone=()"
    # Mitiga o Cross-Origin-Embedder-Policy
    response.headers['Cross-Origin-Embedder-Policy'] = 'require-corp'
    return response

# Tratador global de erro 500 para evitar o "Application Error Disclosure"
@app.errorhandler(500)
def internal_error(error):
    return "Erro interno tratado com seguranca.", 500

# Always put Routes at end
from todo_project import routes
