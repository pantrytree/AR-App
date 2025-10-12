import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/colors.dart';
import '/viewmodels/sign_up_viewmodel.dart';

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignUpViewModel>(
      create: (_) => SignUpViewModel(),
      child: Consumer<SignUpViewModel>(
        builder: (context, model, child) {
          // Navigation handling
          if (model.navigateToRoute != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, model.navigateToRoute!);
              model.clearNavigation();
            });
          }

          return Scaffold(
            body: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.folderPurple,
                        AppColors.buttonPrimary,
                      ],
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Form(
                      key: model.formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Personal details',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 32),
                          TextFormField(
                            style: TextStyle(color: AppColors.secondaryBackground),
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(color: AppColors.secondaryBackground),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.secondaryBackground),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.secondaryBackground),
                              ),
                            ),
                            onChanged: model.setName,
                            validator: model.nameValidator,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            style: TextStyle(color: AppColors.secondaryBackground),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: AppColors.secondaryBackground),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.secondaryBackground),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.secondaryBackground),
                              ),
                            ),
                            onChanged: model.setEmail,
                            validator: model.emailValidator,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            style: TextStyle(color: AppColors.secondaryBackground),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: AppColors.secondaryBackground),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.secondaryBackground),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.secondaryBackground),
                              ),
                            ),
                            obscureText: true,
                            onChanged: model.setPassword,
                            validator: model.passwordValidator,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            style: TextStyle(color: AppColors.secondaryBackground),
                            decoration: InputDecoration(
                              labelText: 'Confirm password',
                              labelStyle: TextStyle(color: AppColors.secondaryBackground),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.secondaryBackground),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.secondaryBackground),
                              ),
                            ),
                            obscureText: true,
                            onChanged: model.setConfirmPassword,
                            validator: model.confirmPasswordValidator,
                          ),
                          SizedBox(height: 32),
                          if (model.errorMessage != null)
                            Text(model.errorMessage!, style: TextStyle(color: Colors.red)),
                          SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: model.loading ? null : model.signUp,
                              child: model.loading
                                  ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                              )
                                  : Text('Sign Up'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryBackground,
                                foregroundColor: AppColors.primaryPurple,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(color: AppColors.secondaryBackground),
                              ),
                              GestureDetector(
                                onTap: model.onSignInTapped,
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondaryBackground),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        color: AppColors.secondaryBackground.withOpacity(0.8),
                        shape: CircleBorder(),
                        child: InkWell(
                          customBorder: CircleBorder(),
                          onTap: model.onBackButtonTapped,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.close, color: Colors.black, size: 28),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
