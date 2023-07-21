import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'api_consumer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'home_screen.dart';

class ItemsUploadScreen extends StatefulWidget {
  const ItemsUploadScreen({super.key});

  @override
  State<ItemsUploadScreen> createState() => _ItemsUploadScreenState();
}

class _ItemsUploadScreenState extends State<ItemsUploadScreen>
{
  Uint8List? imageFileUnit8List;

  TextEditingController sellerNameEditingController = TextEditingController();
  TextEditingController sellerPhoneEditingController = TextEditingController();
  TextEditingController itemNameEditingController = TextEditingController();
  TextEditingController itemDescEditingController = TextEditingController();
  TextEditingController itemPriceEditingController = TextEditingController();
  String downloadUrlOfUploadedImage = "";


  bool isUploading = false;
  //Upload form screen
  Widget uploadFormScreen(){
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Upload New Item",
          style: TextStyle(
            color: Colors.white,

          ),
        ),
        actions: [
          IconButton(
            onPressed: (){
            //  Validation
              if(isUploading!=true){
                validateform();
              }

            },
            icon: const Icon(
              Icons.cloud_upload,
              color: Colors.white,
            ),
          )
        ],
        centerTitle: true,
      ),
      body: ListView(
        children: [
          isUploading  == true
          ? const LinearProgressIndicator(color: Colors.purpleAccent,)
          : Container(),

          SizedBox(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: imageFileUnit8List != null ?
              Image.memory(
                imageFileUnit8List!
              ):const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
              ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 2,
          ),
          //Seller Name
          ListTile(
            leading: const Icon(
              Icons.person_pin_rounded,
              color: Colors.white,

            ),
            title: SizedBox(
              width: 250,
              child:TextField(
                style:const TextStyle(color: Colors.grey),
                controller: sellerNameEditingController,
                decoration: const InputDecoration(
                  hintText: "seller name",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,

                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 1,
          ),

          ListTile(
            leading: const Icon(
              Icons.person_pin_rounded,
              color: Colors.white,

            ),
            title: SizedBox(
              width: 250,
              child:TextField(
                style:const TextStyle(color: Colors.grey),
                controller: sellerPhoneEditingController,
                decoration: const InputDecoration(
                  hintText: "Seller Phone Details",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,

                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 1,
          ),

          ListTile(
            leading: const Icon(
              Icons.person_pin_rounded,
              color: Colors.white,

            ),
            title: SizedBox(
              width: 250,
              child:TextField(
                style:const TextStyle(color: Colors.grey),
                controller: itemNameEditingController,
                decoration: const InputDecoration(
                  hintText: "Item Name",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,

                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 1,
          ),

          ListTile(
            leading: const Icon(
              Icons.person_pin_rounded,
              color: Colors.white,

            ),
            title: SizedBox(
              width: 250,
              child:TextField(
                style:const TextStyle(color: Colors.grey),
                controller: itemDescEditingController,
                decoration: const InputDecoration(
                  hintText: "Item Description",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,

                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 1,
          ),

          ListTile(
            leading: const Icon(
              Icons.person_pin_rounded,
              color: Colors.white,

            ),
            title: SizedBox(
              width: 250,
              child:TextField(
                style:const TextStyle(color: Colors.grey),
                controller: itemPriceEditingController,
                decoration: const InputDecoration(
                  hintText: "Price Details",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,

                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.white70,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  validateform() async{
    if(imageFileUnit8List != null)
    {
      if(sellerNameEditingController.text.isNotEmpty
          && sellerPhoneEditingController.text.isNotEmpty
          && itemNameEditingController.text.isNotEmpty
          && itemDescEditingController.text.isNotEmpty
          && itemPriceEditingController.text.isNotEmpty)
      {
        setState(() {
          isUploading = true;
        });

        //1.upload image to firebase storage
        String imageUniqueName = DateTime.now().millisecondsSinceEpoch.toString();

        fStorage.Reference firebaseStorageRef = fStorage.FirebaseStorage.instance.ref()
            .child("Items Images")
            .child(imageUniqueName);

        fStorage.UploadTask uploadTaskImageFile = firebaseStorageRef.putData(imageFileUnit8List!);

        fStorage.TaskSnapshot taskSnapshot = await uploadTaskImageFile.whenComplete(() {});

        await taskSnapshot.ref.getDownloadURL().then((imageDownloadUrl)
        {
          downloadUrlOfUploadedImage = imageDownloadUrl;
        });

        //2.save item info to firestore database
        saveItemInfoToFirestore();
      }
      else
      {
        Fluttertoast.showToast(msg: "Please complete upload form. Every field is mandatory.");
      }
    }
    else
    {
      Fluttertoast.showToast(msg: "Please select image file.");
    }
  }
  saveItemInfoToFirestore()
  {
    String itemUniqueId = DateTime.now().millisecondsSinceEpoch.toString();

    FirebaseFirestore.instance
        .collection("items")
        .doc(itemUniqueId)
        .set(
        {
          "itemID": itemUniqueId,
          "itemName": itemNameEditingController.text,
          "itemDescription": itemDescEditingController.text,
          "itemImage": downloadUrlOfUploadedImage,
          "sellerName": sellerNameEditingController.text,
          "sellerPhone": sellerPhoneEditingController.text,
          "itemPrice": itemPriceEditingController.text,
          "publishedDate": DateTime.now(),
          "status": "available",
        });

    Fluttertoast.showToast(msg: "your new Item uploaded successfully.");

    setState(() {
      isUploading = false;
      imageFileUnit8List = null;
    });

    Navigator.push(context, MaterialPageRoute(builder: (c)=> const HomeScreen()));
  }

  Widget defalutScene(){
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Upload New Item",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            const Icon(
              Icons.add_photo_alternate,
              color: Colors.white,
              size: 200,
            ),
            ElevatedButton(
              onPressed: (){
                showDialogBox();
              },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),

              child: const Text(
                "Add New Item",
                style: TextStyle(
                  color: Colors.white70,
                )
              )
            ),
          ],
        ),
      ),
    );
  }

  showDialogBox(){
    return showDialog(
      context: context,
      builder: (c){
        return SimpleDialog(
          backgroundColor: Colors.black,
          title: const Text(
            "Item Image",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            SimpleDialogOption(
              onPressed:(){
                capturewithcamera();
              },
              child: const Text(
                "Capture Image With Camera",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed:(){
                fromGallery();

              },
              child: const Text(
                "Upload from Gallery",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed:(){
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      }
    );

  }
  capturewithcamera() async{
    Navigator.pop(context);
    try{
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
      if(pickedImage!=null){
        String path = pickedImage.path;
        imageFileUnit8List = await pickedImage.readAsBytes();

        //Remove Background
        //Make Image Transparent
        imageFileUnit8List = await ApiConsumer().removeImageBackgroundApi(path);
        setState(() {
          imageFileUnit8List;
        });
      }
    }
    catch(errormsg){
      print(errormsg.toString());

      setState(() {
        imageFileUnit8List = null;
      });

    }
  }
  fromGallery() async{
    Navigator.pop(context);
    try{
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(pickedImage!=null){
        String path = pickedImage.path;
        imageFileUnit8List = await pickedImage.readAsBytes();

        //Remove Background
        //Male Image Transparent
        imageFileUnit8List = await ApiConsumer().removeImageBackgroundApi(path);

        setState(() {
          imageFileUnit8List;
        });
      }
    }
    catch(errormsg){
      print(errormsg.toString());

      setState(() {
        imageFileUnit8List = null;
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return imageFileUnit8List == null ? defalutScene() : uploadFormScreen();
  }
}
