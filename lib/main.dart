import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for date formatting

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//test for data storage
Map<String, dynamic> carsMap = {
  "cars": <String, dynamic>
    {
      "Blake's Test Car": <String, dynamic>{
        "parts": <String, dynamic>{
          "Oil and Filter": <String, dynamic>{
            "type": "40 weight synthetic",
            "mileage_left": 1500,
            "expire_date": Timestamp.now()
          },
          "Tires": <String, dynamic>{
            "type": "firestone",
            "mileage_left": 1000,
            "expire_date": Timestamp.now()
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
//the defaults for any new car created
Map <String, dynamic> emptyCarData = {
  "parts": <String, dynamic>{
    "Oil and Filter": <String, dynamic>{
      "type": "default",
      "mileage_left": 0,
      "expire_date":Timestamp.now()
    },
    "Tires": <String, dynamic>{
      "type": "default",
      "mileage_left": 0,
      "expire_date":Timestamp.now()
    },
    "Cabin Filter": <String, dynamic>{
      "type": "default",
      "mileage_left": 0,
      "expire_date":Timestamp.now()
    },
    "Air Filter": <String, dynamic>{
      "type": "default",
      "mileage_left": 0,
      "expire_date":Timestamp.now()
    },
    "Wipers": <String, dynamic>{
      "type": "default",
      "mileage_left": 0,
      "expire_date":Timestamp.now()
    },
  },
  "gas": <Timestamp, dynamic>{
  }
};
//the name of the car to load on the car screen
String carName = "";
//the name of the part to load on the part screen and replace screen
String part = "";
//the user's id
User? user;

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
      user = userCredential.user;
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
      user = userCredential.user;
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

  @override
  void initState() {
    super.initState();
    nameTextBoxController = TextEditingController();
  }
  //tries to add a new car to the user car
  Future<void> tryMakeNewCar() async {
    if(nameTextBoxController.text != "")
    {
      //source/help https://www.androidbugfix.com/2021/12/how-to-update-nested-field-inside.html
      final serverData = await FirebaseFirestore.instance
          .collection("user_cars")
          .doc(user?.uid)
          .get();
      if (serverData.exists) {
        //the actual data to be manipulated
        final localData = serverData.data() as Map<String, dynamic>;
        //get the map of cars data and see if the car name exists in it
        if (!((localData["cars"] as Map<String, dynamic>).containsKey(nameTextBoxController.text))) {
          //set userdoc cars map[new car name] to the emptyCarData
          (localData["cars"] as Map<String, dynamic>)[nameTextBoxController.text] = emptyCarData;
          //push the changes
          await FirebaseFirestore.instance
              .collection("user_cars")
              .doc(user?.uid)
              .update(localData);
        }
      }
      else {
        //create the doc layout for a new user
        final carData = {
          "cars": <String, dynamic>{
            nameTextBoxController.text: emptyCarData
          }
        };
        await FirebaseFirestore.instance
            .collection("user_cars")
            .doc(user?.uid)
            .set(carData);
      }
      //set car path correctly
      carName = nameTextBoxController.text;
      Navigator.pushNamed(context, '/login/car');
    }
  }

  @override
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
          const Padding(padding: EdgeInsets.all(5)),
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

class SelectCarScreen extends StatelessWidget {
  const SelectCarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Select Car'),
          centerTitle: true,
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream:FirebaseFirestore.instance.collection("user_cars")
                .doc(user?.uid)
                .snapshots(),
            builder: (context, snapshot){
              if(!snapshot.hasData) return const LinearProgressIndicator();

              final userCarsMap = (snapshot.data?.data() as Map<String, dynamic>)['cars'] as Map<String, dynamic>;
              return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        //parse the map into each button
                        for(var k in (userCarsMap.keys))
                          CarButton(k)
                      ],
                    ),
                  )
              );
            }
        )
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

class CarScreen extends StatelessWidget {
  const CarScreen({Key? key}) : super(key: key);

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
            ],
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream:FirebaseFirestore.instance.collection("user_cars")
                .doc(user?.uid)
                .snapshots(),
            builder: (context, snapshot){
              if(!snapshot.hasData) return const LinearProgressIndicator();
              //get all the way to the parts map just once to make code way more readable
              final userCarMap = (((snapshot.data?.data()
              as Map<String, dynamic>)['cars']
              as Map<String, dynamic>)[carName]
              as Map <String, dynamic>)["parts"]
              as Map <String, dynamic>;

              return Center(
                  child:SizedBox(
                  height: 600,
                  width: 400,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const Padding(padding: EdgeInsets.all(10)),
                            //parse the map into each button
                            for(var k in (userCarMap.keys))
                            PartButton(
                                k,
                                ((userCarMap[k]as Map <String,dynamic>)["mileage_left"] as int),
                                ((userCarMap[k]as Map <String,dynamic>)["expire_date"] as Timestamp)
                            )
                          ],
                        ),
                      )
                  )
              );
            }
        )
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
  final Timestamp expireDate;

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
                  //this converts the timestamp into datetime for better formatting
                  child: Text( "Mileage: " + mileage.toString() +" Expires: " + DateFormat("MMMM d").
                  format(DateTime.fromMicrosecondsSinceEpoch(expireDate.microsecondsSinceEpoch)).toString()),
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
      body:
      StreamBuilder<DocumentSnapshot>(
          stream:FirebaseFirestore.instance.collection("user_cars")
              .doc(user?.uid)
              .snapshots(),
          builder: (context, snapshot){
            if(!snapshot.hasData) return const LinearProgressIndicator();
            //get all the way to the part map just once to make code way more readable
            final userPartMap = ((((snapshot.data?.data()
            as Map<String, dynamic>)['cars']
            as Map<String, dynamic>)[carName]
            as Map <String, dynamic>)["parts"]
            as Map <String, dynamic>)[part]
            as Map<String, dynamic>;
            return Center(
              child: Column(
                children: [
                  const Padding(padding: EdgeInsets.all(10)),
                  SizedBox(
                      height: 50,
                      width: 400,
                      //a parse to get the part description
                      child: Text("Type: " + userPartMap["type"]),
                  ),
                  const Padding(padding: EdgeInsets.all(10)),
                  SizedBox(
                      height: 50,
                      width: 400,
                      //a parse to get the part mileage
                      child: Text("Mileage Left: " + (userPartMap["mileage_left"] as int).toString()),
                  ),
                  const Padding(padding: EdgeInsets.all(10)),
                  SizedBox(
                      height: 50,
                      width: 400,
                      //a parse to get the part expiration date with conversions from Timestamp to DateTime for formatting
                      child: Text("Expiration Date:" +
                          (DateFormat("MMMM d").format(DateTime.fromMicrosecondsSinceEpoch(
                              (userPartMap["expire_date"] as Timestamp).microsecondsSinceEpoch)
                          ).toString()),
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
            );
          }
      )
    );
  }
}

class ReplaceScreen extends StatefulWidget {
  const ReplaceScreen({Key? key}) : super(key: key);

  @override
  _ReplaceScreenState createState() => _ReplaceScreenState();
}

class _ReplaceScreenState extends State<ReplaceScreen> {
  late TextEditingController descTextBoxController;
  late TextEditingController milesTextBoxController;
  late TextEditingController monthsTextBoxController;

  @override
  void initState() {
    super.initState();

    descTextBoxController = TextEditingController();
    milesTextBoxController = TextEditingController();
    monthsTextBoxController = TextEditingController();
  }
//Checks if the input is valid then attempts to override the part for that car
  Future<void> tryUpdatePart() async{
    //double check the text boxes have valid data
    int miles = int.parse(milesTextBoxController.text);
    int months = int.parse(monthsTextBoxController.text);
    if(miles > 0 &&  months > 0 && descTextBoxController.text != '') {
      //get the correct expire date there is probably a better way to do this by adding in the inputted months to the current date.
      //I have no idea what this would do in a case that would end up in for example the 31st of a month that doesn't have it
      Timestamp expireDate = Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month + months, DateTime.now().day));

      //source/help https://www.androidbugfix.com/2021/12/how-to-update-nested-field-inside.html
      final serverData = await FirebaseFirestore.instance
          .collection("user_cars")
          .doc(user?.uid)
          .get();
      if (serverData.exists) {
        //the actual data to be manipulated
        final localData = serverData.data() as Map<String, dynamic>;
        //some nasty parses to get to the required data to overwrite. I do not use a new variable because I am scared of the results
        //set the part description
        ((((localData["cars"]
        as Map <String, dynamic>)[carName]
        as Map <String, dynamic>)["parts"]
        as Map <String, dynamic>)[part]
        as Map <String, dynamic>)["type"] = descTextBoxController.text;
        //set miles left
        ((((localData["cars"]
        as Map <String, dynamic>)[carName]
        as Map <String, dynamic>)["parts"]
        as Map <String, dynamic>)[part]
        as Map <String, dynamic>)["mileage_left"] = miles;
        //set expire date
        ((((localData["cars"]
        as Map <String, dynamic>)[carName]
        as Map <String, dynamic>)["parts"]
        as Map <String, dynamic>)[part]
        as Map <String, dynamic>)["expire_date"] = expireDate;

        //upload to the server
        await FirebaseFirestore.instance
            .collection("user_cars")
            .doc(user?.uid)
            .set(localData);

        //go back to the part screen
        Navigator.pop(context);
      }
      else{
        //user doesn't exist this shouldn't happen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Replace ' + part),
        centerTitle: true,
      ),
      body:
          Align(alignment: Alignment.center,
          child: Column(
            children: [
              Text("What specific " + part + " did you put in ?"),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: descTextBoxController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Description",
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.all(2)),
              const Text("How many miles until this part needs to be changed?"),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: milesTextBoxController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.all(2)),
              const Text("How many months until this part needs to be changed?"),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: monthsTextBoxController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.all(2)),
              ElevatedButton(
                  onPressed: (){
                    tryUpdatePart();
                  },
                  child: const Text("Replace Part"))
            ],
          ),
          )
    );
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
