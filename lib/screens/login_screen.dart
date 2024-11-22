import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../utils/current_user.dart'; // Importa a classe CurrentUser
import 'task_list_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24736E), // Fundo verde escuro
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo grande
                Image.asset(
                  'assets/images/logo.png',
                  height: 300, // Tamanho ajustado para a logo
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),

                // Nome do App
                const Text(
                  'ClearTask+',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF85DDBE), // Verde claro
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Texto abaixo do nome do app
                const Text(
                  'Organize seu dia, realize suas metas!\nTransforme tarefas em conquistas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white, // Texto branco
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),

                // Caixa de texto: E-mail
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Color(0xFF24736E)), // Texto verde escuro
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white, // Fundo branco
                    hintText: 'E-mail',
                    hintStyle: const TextStyle(color: Color(0xFF24736E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Caixa de texto: Senha
                TextField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  style: const TextStyle(color: Color(0xFF24736E)), // Texto verde escuro
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white, // Fundo branco
                    hintText: 'Senha',
                    hintStyle: const TextStyle(color: Color(0xFF24736E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF24736E),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Botão: Esqueci a senha
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Recuperação de Senha'),
                          content: const Text(
                              'Um e-mail foi enviado para recuperar sua senha.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'Esqueci a senha',
                      style: TextStyle(
                        color: Color(0xFF85DDBE), // Verde claro do protótipo
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Botão: Entrar
                SizedBox(
                  width: double.infinity, // Largura igual às caixas de texto
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Preencha todos os campos!')),
                        );
                        return;
                      }

                      final dbHelper = DatabaseHelper.instance;
                      final user = await dbHelper.getUserByEmailAndPassword(email, password);

                      if (user != null) {
                        // Armazena o usuário logado
                        CurrentUser.setUser(user['name'], user['email']);

                        // Navega para a tela de lista de tarefas
                        Navigator.pushReplacementNamed(
                            context, TaskListScreen.routeName);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Credenciais inválidas!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        color: Color(0xFF24736E),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Botão: Entrar com o Google
                SizedBox(
                  width: double.infinity, // Largura igual às caixas de texto
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Lógica de login com o Google (simulada)
                    },
                    icon: ClipOval(
                      child: Image.asset(
                        'assets/images/google_icon.png',
                        height: 30,
                        width: 30,
                        fit: BoxFit.cover,
                      ),
                    ),
                    label: const Text(
                      'Entrar com o Google',
                      style: TextStyle(
                        color: Color(0xFF24736E),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Botão: Registre-se
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    'Registre-se',
                    style: TextStyle(
                      color: Color(0xFF85DDBE), // Verde claro do protótipo
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Botão: Ajuda e Suporte
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.help, color: Color(0xFF85DDBE)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Ajuda e Suporte'),
                    content: const Text('Entre em contato via support@cleartask.com'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
