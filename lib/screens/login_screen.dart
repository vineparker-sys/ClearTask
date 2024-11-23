import 'dart:math';

import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../utils/current_user.dart'; // Importa a classe CurrentUser
import 'task_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _rememberMe = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoggedIn(); // Verifica o estado inicial
  }

  void _checkLoggedIn() async {
    await Future.delayed(Duration(seconds: 2)); 
    
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final List<String>? user = prefs.getStringList('User');

     setState(() {
      _rememberMe = isLoggedIn;
      _isLoading = false; // Termina o carregamento
    });

    if (context.mounted) {
      if (isLoggedIn) {
        if(user != null){
        CurrentUser.setUser(user[0], user[1]);
        Navigator.pushReplacementNamed(context, TaskListScreen.routeName);
        }
      }
    }
  }

  Future<void> _login(Map<String, dynamic> user) async {
    // Armazena o usuário logado
    CurrentUser.setUser(user['name'], user['email']);

    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      // Set a flag to remember the user
      await prefs.setBool('isLoggedIn', true);
      await prefs.setStringList('User', [user['name'], user['email']]);
    }
    // Navigate to main screen after login
    Navigator.pushReplacementNamed(context, TaskListScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
     if (_isLoading) {
      // Exibe um indicador de carregamento enquanto verifica o login
      return Scaffold(
        backgroundColor: const Color(0xFF24736E),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white), // Carregando...
        ),
      );
    }

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
                  style: const TextStyle(
                      color: Color(0xFF24736E)), // Texto verde escuro
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
                  style: const TextStyle(
                      color: Color(0xFF24736E)), // Texto verde escuro
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
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                // Checkbox "Lembre-se de mim"
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (bool? value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      checkColor: Colors.white,
                      activeColor: Colors.teal,
                    ),
                    const Text(
                      'Lembre-se de mim',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
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
                          const SnackBar(
                              content: Text('Preencha todos os campos!')),
                        );
                        return;
                      }

                      final dbHelper = DatabaseHelper.instance;
                      final user = await dbHelper.getUserByEmailAndPassword(
                          email, password);

                      if (user != null) {
                        _login(user);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Credenciais inválidas!')),
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
                // Esqueci minha senha e Registrar-se
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
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
                            color:
                                Color(0xFF85DDBE), // Verde claro do protótipo
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '/',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          'Registre-se',
                          style: TextStyle(
                            color:
                                Color(0xFF85DDBE), // Verde claro do protótipo
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
                    content: const Text(
                        'Entre em contato via support@cleartask.com'),
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
