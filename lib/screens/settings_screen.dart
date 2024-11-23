import 'package:ClearTask/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/current_user.dart'; // Corrigido para usar CurrentUser
import 'task_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userName = 'Usuário';
  String userEmail = 'E-mail não disponível';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      userName = CurrentUser.name ?? 'Usuário';
      userEmail = CurrentUser.email ?? 'E-mail não disponível';
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor =
        isDarkMode ? const Color(0xFF05F7C0) : const Color(0xFF24746C);
    final secondaryTextColor =
        isDarkMode ? const Color(0xFF7C808D) : Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        title: Text(
          'Configurações',
          style: TextStyle(color: textColor),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header com imagem de perfil
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/user.png'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 16,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Opções de configuração
            _buildSectionTitle('GERAL', textColor),
            _buildListTile(
              context,
              title: 'Minha conta',
              icon: Icons.person,
              textColor: textColor,
              onTap: () {
                // Ação para abrir página de conta (exemplo)
              },
            ),
            _buildListTile(
              context,
              title: 'Editar preferências',
              icon: Icons.edit,
              textColor: textColor,
              onTap: () {
                // Ação para editar preferências
              },
            ),
            _buildListTile(
              context,
              title: 'Personalização e Idioma',
              icon: Icons.language,
              textColor: textColor,
              onTap: () {
                // Ação para personalização
              },
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('TEMA E NOTIFICAÇÕES', textColor),
            _buildSwitchTile(
              title: 'Notificações',
              value: themeProvider.notificationsEnabled,
              onChanged: (value) {
                themeProvider.toggleNotifications(value);
              },
              textColor: textColor,
            ),
            _buildSwitchTile(
              title: 'Modo escuro',
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleDarkMode(value);
              },
              textColor: textColor,
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('SOBRE A APLICAÇÃO', textColor),
            _buildListTile(
              context,
              title: 'Política de Privacidade',
              icon: Icons.privacy_tip,
              textColor: textColor,
              onTap: () {
                // Abrir política de privacidade
              },
            ),
            _buildListTile(
              context,
              title: 'Termos de uso',
              icon: Icons.description,
              textColor: textColor,
              onTap: () {
                // Abrir termos de uso
              },
            ),

            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () async {
                  // Limpar SharedPreferences
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.clear();
                  CurrentUser.clearUser();

                  // Navegar para a tela de login
                  Navigator.pushReplacementNamed(
                      context, LoginScreen.routeName);
                },
                child: Text(
                  'Sair',
                  style: TextStyle(
                      color: Colors.red, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryTextColor,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, TaskListScreen.routeName);
          } else if (index == 1) {
            // Ação para abrir lista de todas as tarefas (ainda a ser implementada)
          }
        },
        currentIndex: 0, // Define o item selecionado
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap,
      required Color textColor}) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: Icon(Icons.chevron_right, color: textColor),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
      {required String title,
      required bool value,
      required ValueChanged<bool> onChanged,
      required Color textColor}) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(color: textColor)),
      activeColor: textColor,
      value: value,
      onChanged: onChanged,
    );
  }
}
