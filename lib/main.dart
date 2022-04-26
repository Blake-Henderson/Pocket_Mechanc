/*
  questions for Eric
  editing/adding onto firebase maps
  error text not showing up
  how to make things not ugly/flex color scheme themes
  different keyboards for input needed for both parts screen and gas screen
  how close to the UI layout do we have to get
*/
import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for date formatting
import 'package:flex_color_scheme/flex_color_scheme.dart'; // for themes

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

//test for data storage
Map<String, dynamic> carsMap = {
  "cars": <String, dynamic>
    {
      "Blake's Test Car": <String, dynamic>{
        "parts": <String, dynamic>{
          "Oil and Filter": <String, dynamic>{
            "type": "40 weight synthetic",
            "mileage_left": 1500,
            "expire_date": DateTime(2022, 12, 31)
          },
          "Tires": <String, dynamic>{
            "type": "firestone",
            "mileage_left": 1000,
            "expire_date": DateTime(2022, 12, 31)
          },
        },
        "gas": <DateTime, dynamic>{
          DateTime(2022, 10, 31): <String, dynamic>{
            "odometer": 100000,
            "gas_filled": 5,
            "mpg": "unknown"
          },
          DateTime(2022, 11, 31): <String, dynamic>{
            "odometer": 100050,
            "gas_filled": 5,
            "mpg": 0
          },
          DateTime(2022, 12, 31): <String, dynamic>{
            "odometer": 100150,
            "gas_filled": 5,
            "mpg": 0
          }
        }
      },
      "Ford": <String, dynamic>{
        "parts": <String, dynamic>{
          "Oil and Filter": <String, dynamic>{
            "type": "50 weight synthetic",
            "mileage_left": 500,
            "expire_date": DateTime(5, 30, 2022)
          },
          "Tires": <String, dynamic>{
            "type": "Generic",
            "mileage_left": 100,
            "expire_date": DateTime(5, 2, 2022)
          },
          "Cabin Filter": <String, dynamic>{
            "type": "Some Brand",
            "mileage_left": 50,
            "expire_date": DateTime(2022, 12, 31)
          },
          "Wipers": <String, dynamic>{
            "type": "Factory",
            "mileage_left": 10000,
            "expire_date": DateTime(2022, 12, 31)
          },
        },
        "gas": <DateTime, dynamic>{
          DateTime(2022, 12, 21): <String, dynamic>{
            "odometer": 100000,
            "gas_filled": 5,
            "mpg": "unknown"
          },
          DateTime(2022, 12, 30): <String, dynamic>{
            "odometer": 100050,
            "gas_filled": 5,
            "mpg": 0
          },
          DateTime(2022, 12, 31): <String, dynamic>{
            "odometer": 100150,
            "gas_filled": 5,
            "mpg": 0
          }
        }
      }
    },
};
//the name of the car to load on the car screen
String carName = "";
//the name of the part to load on the part screen and replace screen
String part = "";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAQMqjcuw_KDS3LObDedDOgDs-w009rhgs",
            authDomain: "pocket-mechanic-bfbd8.firebaseapp.com",
            projectId: "pocket-mechanic-bfbd8",
            storageBucket: "pocket-mechanic-bfbd8.appspot.com",
            messagingSenderId: "800502867905",
            appId: "1:800502867905:web:66692617fea29aedc93140",
            measurementId: "G-KTQV5WJQLJ"));
  }

  runApp(MaterialApp(
    title: 'Pocket Mechanic',
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const SplashScreen(),
      '/login': (context) => const LoginScreen(),
      '/login/newCar': (context) => const NewCarScreen(),
      '/login/selectCar': (context) => const SelectCarScreen(),
      '/login/car': (context) => const CarScreen(),
      '/login/car/gas': (context) => const GasScreen(),
      '/login/car/part': (context) => const PartScreen(),
      '/login/car/part/replace': (context) => const ReplaceScreen()
    },
  ));
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Pocket Mechanic',
        ),
        const Padding(padding: EdgeInsets.all(10)),
        ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text(
              'Login',
            ))
      ],
    )));
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailTextBoxController;
  late TextEditingController passwordTextBoxController;
  String errorText = "";

  @override
  void initState() {
    super.initState();
    emailTextBoxController = TextEditingController();
    passwordTextBoxController = TextEditingController();
  }

  Future<void> tryToSignIn() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextBoxController.text,
        password: passwordTextBoxController.text,
      );
      errorText = "";
      Navigator.pushNamed(context, '/login/selectCar');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorText = "user not found";
      } else if (e.code == 'wrong-password') {
        errorText = "wrong password";
        print("wrong");
      }
    } catch (e) {
        errorText = e.toString();
    }
  }

  Future<void> tryToSignUp() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailTextBoxController.text,
              password: passwordTextBoxController.text);
      errorText = "";
      Navigator.pushNamed(context, '/login/newCar');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        errorText = "weak password";
      } else if (e.code == 'email-already-in-use') {
        errorText = "email already in use";
      }
    } catch (e) {
      errorText = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(children: [
          const Padding(padding: EdgeInsets.all(5)),
          Text(errorText),
          const Padding(padding: EdgeInsets.all(5)),
          SizedBox(
            width: 200,
            child: TextField(
              controller: emailTextBoxController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(5)),
          SizedBox(
            width: 200,
            child: TextField(
              obscureText: true,
              controller: passwordTextBoxController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  tryToSignIn();
                },
                child: const Text('Sign In!'),
              ),
              const Padding(padding: EdgeInsets.all(5)),
              ElevatedButton(
                onPressed: () {
                  tryToSignUp();
                },
                child: const Text('Sign Up!'),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

class NewCarScreen extends StatefulWidget {
  const NewCarScreen({Key? key}) : super(key: key);

  @override
  _NewCarScreenState createState() => _NewCarScreenState();
}

class _NewCarScreenState extends State<NewCarScreen> {
  late TextEditingController nameTextBoxController;
  late String errorText;

  @override
  void initState() {
    super.initState();
    nameTextBoxController = TextEditingController();
    errorText = '';
  }

  Future<void> tryMakeNewCar() async {
    //implement checking to see if user already has car with that name
    //and create a car with that name
    Navigator.pushNamed(context, '/login/car');
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create A New Car'),
          centerTitle: true,
        ),
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("What would you like to call this car?"),
          const Padding(padding: EdgeInsets.all(5)),
          SizedBox(
            width: 200,
            child: TextField(
              controller: nameTextBoxController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Car',
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(5)),
          ElevatedButton(
            onPressed: () {
              tryMakeNewCar();
            },
            child: const Text('Create Car!'),
          ),
        ],
      ),
    ));
  }
}

class SelectCarScreen extends StatefulWidget {
  const SelectCarScreen({Key? key}) : super(key: key);

  @override
  _SelectCarScreenState createState() => _SelectCarScreenState();
}

class _SelectCarScreenState extends State<SelectCarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Car'),
      ),
      //todo StreamBuilder
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //parse the map into each button
              for(var k in (carsMap["cars"] as Map <String,dynamic>).keys)
                CarButton(k)
            ],
          ),
        ),
      ),
    );
  }
}

//this button is used by the SelectCarScreen to select which car they want to use
class CarButton extends StatelessWidget {
  const CarButton(this.name, {Key? key}) : super(key: key);
  final String name;

  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        const Padding(padding: EdgeInsets.all(5)),
        SizedBox(
          height: 20,
          width: 150,
          child: ElevatedButton(
            onPressed: (){
              carName = name;
              Navigator.pushNamed(context, '/login/car');
            },
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(name),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class CarScreen extends StatefulWidget {
  const CarScreen({Key? key}) : super(key: key);

  @override
  _CarScreenState createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(carName),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: const Text("Gas Mileage"),
              onTap: (){Navigator.pushNamed(context, '/login/car/gas');},
            ),
            ListTile(
              title: const Text("Change Car"),
              onTap: (){Navigator.pushNamed(context, '/login/selectCar');},
            ),
            ListTile(
              title: const Text("New Car"),
              onTap: (){Navigator.pushNamed(context, '/login/newCar');},
            ),
            ListTile(
              //ask Eric
              title: const Text("Exit"),
              onTap: (){},
            ),
          ],
        ),
      ),
      body: Center(
        child:
          SizedBox(
            height: 600,
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                 children: [
                   /* todo add streambuilder
                   parsing the map to get to the individual car's sub-map of parts sub-map of part data also known as the parse to end all parses

                        multiple choice question time: How much caffeine did I consume to figure this out?
                        A. a reasonable amount
                        B. a concerning amount
                        C. enough to kill a normal human
                        D. enough to kill a small elephant
                  */
                for(var k in (((carsMap["cars"] as Map <String,dynamic>)
                [carName] as Map <String,dynamic>)["parts"]).keys)
                    PartButton(
                        k,
                        ((((((carsMap["cars"] as Map <String,dynamic>)[carName] as Map <String,dynamic>)["parts"]) as Map <String,dynamic>)[k]as Map <String,dynamic>)["mileage_left"] as int),
                        ((((((carsMap["cars"] as Map <String,dynamic>)[carName] as Map <String,dynamic>)["parts"]) as Map <String,dynamic>)[k]as Map <String,dynamic>)["expire_date"] as DateTime)
                    )
                 ],
              ),
            ),
          )
      ),
    );
  }
}
//this button is used by the car screen to display all of the parts for the car
class PartButton extends StatelessWidget{
 const PartButton(
      this.partType,
      this.mileage,
      this.expireDate,
      {Key? key}): super(key: key);

  final String partType;
  final int mileage;
  final DateTime expireDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.all(5)),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (){
              part = partType;
              Navigator.pushNamed(context, '/login/car/part');
            },
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(partType),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text( "Mileage: " + mileage.toString() +" Expires: " + DateFormat("MMMM d").format(expireDate).toString()),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class PartScreen extends StatelessWidget {
  const PartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(part),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(10)),
            SizedBox(
              height: 100,
              width: 400,
              //a big parse to get the part description
              child: Text(((((((carsMap["cars"] as Map <String,dynamic>)[carName] as Map <String,dynamic>)
              ["parts"]) as Map <String,dynamic>)[part]as Map <String,dynamic>)["type"] as String),
            )
            ),
            const Padding(padding: EdgeInsets.all(10)),
            SizedBox(
                height: 50,
                width: 400,
                //a big parse to get the part mileage
                child: Text(((((((carsMap["cars"] as Map <String,dynamic>)[carName] as Map <String,dynamic>)
                ["parts"]) as Map <String,dynamic>)[part]as Map <String,dynamic>)["mileage_left"] as int).toString(),
                )
            ),
            const Padding(padding: EdgeInsets.all(10)),
            SizedBox(
                height: 50,
                width: 400,
                //a big parse to get the part expiration date with more formatting
                child: Text(DateFormat("MMMM d").format(((((((carsMap["cars"] as Map <String,dynamic>)[carName] as Map <String,dynamic>)
                ["parts"]) as Map <String,dynamic>)[part]as Map <String,dynamic>)["expire_date"] as DateTime)).toString(),
                )
            ),
            const Padding(padding: EdgeInsets.all(10)),
            Align(
            alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login/car/part/replace');
                },
                child: const Text("Replace"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ReplaceScreen extends StatefulWidget {
  const ReplaceScreen({Key? key}) : super(key: key);

  @override
  _ReplaceScreenState createState() => _ReplaceScreenState();
}

class _ReplaceScreenState extends State<ReplaceScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class GasScreen extends StatefulWidget {
  const GasScreen({Key? key}) : super(key: key);

  @override
  _GasScreenState createState() => _GasScreenState();
}

class _GasScreenState extends State<GasScreen> {
  late TextEditingController descTextBoxController;
  late TextEditingController mileageTextBoxController;
  late TextEditingController dateTextBoxController;
  String errorText = "";

  @override
  void initState() {
    super.initState();
    descTextBoxController = TextEditingController();
    TextEditingController mileageTextBoxController = TextEditingController();
    TextEditingController dateTextBoxController = TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gas Summary"),
        centerTitle: true,
      ),
      body: Center(

      ),
    );
  }
}