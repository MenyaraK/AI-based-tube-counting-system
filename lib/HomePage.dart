import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class ArticleDataSource extends DataGridSource {
  List<DataGridRow> _articleData = [];

  ArticleDataSource(List<Article> articleData) {
    _articleData = articleData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'Produit', value: e.Produit),
              DataGridCell<int>(columnName: 'QteBL', value: e.QteBL),
              DataGridCell<int>(columnName: 'QteSaisie', value: e.QTsaisie),
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _articleData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textController = TextEditingController();
  String dropdownValue = 'BL1';
  var dropdownItems = ['BL1', 'BL2', 'BL3', 'BL4', 'BL5'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Veuillez choisir un BL:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: dropdownItems.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
            ),
            SfDataGrid(
              source: ArticleDataSource(getArticleData()),
              columnWidthMode: ColumnWidthMode.fill,
              columns: <GridColumn>[
                GridColumn(
                    columnName: 'Produit',
                    label: Container(
                        padding: EdgeInsets.all(16.0),
                        alignment: Alignment.center,
                        child: Text(
                          'Produit',
                        ))),
                GridColumn(
                    columnName: 'QteBL',
                    label: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text('QteBL'))),
                GridColumn(
                    columnName: 'QteSaisie',
                    label: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text(
                          'QteSaisie',
                          overflow: TextOverflow.ellipsis,
                        ))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

List<Article> getArticleData() {
  return [
    Article('PVC25', 20, 20),
    Article('PVC25', 20, 20),
    Article('PVC25', 20, 20),
    Article('PVC25', 20, 20),
    Article('PVC25', 20, 20),
    Article('PVC25', 20, 20),
    Article('PVC25', 20, 20),
    Article('PVC25', 20, 20),
    Article('PVC25', 20, 20),
    Article('PVC25', 20, 20),
  ];
}

class Article {
  final String Produit;
  final int QteBL;
  final int QTsaisie;
  const Article(this.Produit, this.QteBL, this.QTsaisie);
}
