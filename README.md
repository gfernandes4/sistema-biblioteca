# Sistema Biblioteca Digital

Um aplicativo Flutter cross-platform (desktop e mobile) para gerenciamento de biblioteca digital voltado para escolas públicas.

## 🚀 Funcionalidades

### Implementadas (MVP)
- ✅ **Login Admin**: Autenticação para administradores com token JWT
- ✅ **Login Escola**: Autenticação para representantes de escolas
- ✅ **Acesso Aluno**: Acesso anônimo para busca e leitura
- ✅ **Cadastro de Livros**: Upload de arquivos PDF/EPUB com metadados
- ✅ **Remoção de Livros**: Exclusão de livros (apenas Admin/Escola)
- ✅ **Buscar Livros**: Busca por título, autor ou categoria
- ✅ **Leitura de Livros**: Visualizador de PDF integrado
- ✅ **Temas**: Suporte a modo claro/escuro
- ✅ **Cache Offline**: Armazenamento local de livros para acesso offline

### Planejadas (Futuras versões)
- 🔄 Filtros avançados de busca
- 🔄 Sistema de download com aprovações
- 🔄 Suporte a audiobook
- 🔄 Marcador de páginas
- 🔄 Sincronização avançada offline

## 🏗️ Arquitetura

O projeto segue os princípios de **Clean Architecture** com separação clara entre camadas:

```
lib/
├── main.dart                    # Ponto de entrada da aplicação
└── src/
    ├── core/                    # Componentes centrais
    │   ├── constants/           # Constantes da aplicação
    │   ├── errors/              # Classes de erro/falha
    │   ├── services/            # Serviços principais (API, Database, Storage)
    │   └── utils/               # Utilitários (temas, helpers)
    ├── data/                    # Camada de dados
    │   ├── datasources/         # Fontes de dados (API, Local)
    │   ├── models/              # Modelos para serialização
    │   └── repositories/        # Implementação dos repositórios
    ├── domain/                  # Lógica de negócio
    │   ├── entities/            # Entidades puras
    │   └── usecases/            # Casos de uso
    └── presentation/            # Camada de apresentação
        ├── providers/           # Gerenciamento de estado (Provider)
        ├── screens/             # Telas da aplicação
        └── widgets/             # Widgets reutilizáveis
```

## 🛠️ Tecnologias

### Backend (Assumido)
- **Python + Flask**: API REST
- **MySQL**: Banco de dados na nuvem
- **JWT**: Autenticação

### Frontend (Flutter)
- **Flutter 3.x**: Framework UI
- **Provider**: Gerenciamento de estado
- **SQLite**: Cache local offline
- **HTTP**: Comunicação com API
- **Syncfusion PDF Viewer**: Visualização de PDFs
- **Shared Preferences**: Armazenamento de preferências

## 📱 Configuração e Execução

### Pré-requisitos
- Flutter SDK 3.8.1+
- Dart SDK
- Backend Python + Flask rodando (assumido em `http://localhost:5000`)

### Instalação

1. **Clone o repositório**:
```bash
git clone <url-do-repositorio>
cd sistema-biblioteca
```

2. **Instale as dependências**:
```bash
flutter pub get
```

3. **Configure o backend**:
   - Certifique-se que o backend Flask está rodando em `http://localhost:5000`
   - Endpoints assumidos:
     - `POST /api/login` - Autenticação
     - `GET /api/books` - Listar livros
     - `POST /api/books` - Cadastrar livro
     - `GET /api/search?query=` - Buscar livros
     - `POST /api/upload` - Upload de arquivo

4. **Execute a aplicação**:
```bash
flutter run
```

## 👥 Tipos de Usuário

### 1. Admin
- **Acesso**: Total ao sistema
- **Funcionalidades**: 
  - Gerenciar livros (criar, editar, excluir)
  - Gerenciar usuários
  - Relatórios

### 2. Escola
- **Acesso**: Limitado ao gerenciamento de livros
- **Funcionalidades**:
  - Cadastrar livros
  - Remover livros
  - Buscar e ler livros

### 3. Aluno
- **Acesso**: Anônimo (sem cadastro individual)
- **Funcionalidades**:
  - Buscar livros
  - Ler livros disponíveis
  - Acesso offline aos livros em cache

## 🔒 Autenticação

O sistema utiliza autenticação baseada em JWT:

1. **Login**: Usuário insere email/senha
2. **Token**: API retorna JWT válido
3. **Armazenamento**: Token salvo localmente
4. **Requisições**: Token enviado no header `Authorization: Bearer <token>`
5. **Logout**: Token removido do dispositivo

## 📱 Interface

### Temas
- **Modo Claro**: Interface clara para uso diurno
- **Modo Escuro**: Interface escura para leitura noturna
- **Automático**: Segue configuração do sistema

### Responsividade
- **Desktop**: Interface otimizada para telas grandes
- **Mobile**: Interface adaptada para dispositivos móveis
- **Tablet**: Layout híbrido

## 🗄️ Armazenamento

### Remoto (API)
- Livros e metadados
- Usuários e autenticação
- Sincronização em tempo real

### Local (SQLite)
- Cache de livros para acesso offline
- Configurações do usuário
- Dados de sessão

## 🚦 Estados da Aplicação

### Loading States
- Carregamento de livros
- Upload de arquivos
- Autenticação

### Error States
- Erro de rede
- Arquivo não encontrado
- Falha na autenticação

### Empty States
- Nenhum livro encontrado
- Resultados de busca vazios
- Cache vazio

## 🔄 Funcionalidades Offline

- **Cache Automático**: Livros baixados ficam disponíveis offline
- **Busca Local**: Busca funciona mesmo sem internet
- **Sincronização**: Dados sincronizam quando conexão é restaurada

## 🧪 Testes

Para executar os testes (quando implementados):

```bash
# Testes unitários
flutter test

# Testes de integração
flutter test integration_test/
```

## 📈 Performance

### Otimizações Implementadas
- Cache inteligente de imagens
- Carregamento lazy de listas
- Compressão de imagens
- Pool de conexões HTTP

### Monitoramento
- Logs estruturados
- Métricas de performance
- Tratamento de exceções

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para detalhes.

## 📞 Suporte

Para dúvidas ou suporte:
- 📧 Email: suporte@bibliotecadigital.com
- 📱 WhatsApp: (xx) xxxx-xxxx
- 🌐 Site: www.bibliotecadigital.com

---

**Desenvolvido com ❤️ para democratizar o acesso à educação através da tecnologia.**