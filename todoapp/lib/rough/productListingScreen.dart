import 'dart:async';
import 'dart:convert';
import 'package:admin_panel/models/productModel.dart';
import 'package:admin_panel/presentation/appStartupAuthorisation/accessDeniedScreen.dart';
import 'package:admin_panel/presentation/addproducts/addProductScreen.dart';
import 'package:admin_panel/presentation/addproducts/editProductScreen.dart';
import 'package:admin_panel/presentation/addproducts/filterOptions.dart';
import 'package:admin_panel/presentation/addproducts/productDetailsScreen.dart';
import 'package:admin_panel/presentation/addproducts/sortOptions.dart';
import 'package:admin_panel/presentation/appStartupAuthorisation/checkAccess.dart';
import 'package:admin_panel/presentation/appStartupAuthorisation/dashBoardScreen.dart';
import 'package:admin_panel/presentation/commonUI/appBar.dart';
import 'package:admin_panel/presentation/commonUI/sideDrawer.dart';
import 'package:admin_panel/services/tokenId.dart';
import 'package:admin_panel/utils/productInfo.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  String selectedSortData = '';
  String order = 'desc';
  String creatorPhone = '';
  String creatorName = '';
  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();

  List<ProductData> filteredProducts = [];
  String token = TokenId.token;
  String searchQuery = '';
  int page = 1;
  bool isLoading = true;
  Timer? _debounce;
  String categories = '';
  List<String> subCategories = [];
  List<dynamic> objects = ['', ''];
  String startDate = '';
  String endDate = '';
  bool scroll = false;
  bool isSearchapplied = false;
  bool isfilterapplied = false;
  bool isSortapplied = false;
  bool _allOrdersLoaded = false;
  int totalResultsFound = 0;
  String barCodeFilter = '';

  @override
  void initState() {
    super.initState();

    _checkAccessAndInitialize();
  }

  Future<void> _checkAccessAndInitialize() async {
    bool hasAccess =
        await checkAccess(['Products Listing Admin', 'Super Admin']);
    if (!hasAccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UnauthorizedAccessScreen()),
      );
    } else {
      setState(() {
        isLoading = false;
        fetchProductData();
        handleProductData();
      });
    }
  }

  Widget buildNoResultheader(
    List<ProductData> filteredproducts,
  ) {
    print('inside build no header ');
    setState(() {
      totalResultsFound = 0;
      _allOrdersLoaded = false;
    });
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Gap(30),
        if (filteredproducts.isEmpty && (isSearchapplied || isfilterapplied))
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                Icons.search_off_rounded,
                color: Colors.red,
                size: 50,
              ),
              Gap(4),
              Text(
                'Nothing matches your search!\nTry something else',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
      ],
    );
  }

  bool checkFilterAppliedOrNot() {
    if (categories.isEmpty && creatorPhone.isEmpty && barCodeFilter.isEmpty)
      return false;
    else
      return true;
  }

  Widget buildresultheader(
    List<ProductData> filteredproducts,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isfilterapplied ||
              isSearchapplied ||
              isSortapplied ||
              barCodeFilter.isNotEmpty ||
              startDate.isNotEmpty)
            Row(
              children: [
                const Gap(15),
                Chip(
                  label: const Text(
                    'Clear all',
                    style: TextStyle(
                      color: Color.fromARGB(255, 124, 124, 124),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  deleteIcon: const Icon(
                    Icons.cancel,
                  ),
                  onDeleted: () {
                    setState(() {
                      filteredProducts.clear();
                      isSearchapplied = false;
                      _allOrdersLoaded = false;
                      searchQuery = '';
                      creatorName = '';
                      creatorPhone = '';
                      startDate = '';
                      endDate = '';
                      isSortapplied = false;
                      selectedSortData = '';
                      isfilterapplied = false;
                      categories = '';
                      subCategories = [];
                      page = 1;
                      searchController.clear();
                      barCodeFilter = '';
                      fetchProductData();
                    });
                  },
                ),
                const Gap(3),
                if (isSearchapplied)
                  Chip(
                    label: Text(
                      'Search: "$searchQuery" ',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 124, 124, 124),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    deleteIcon: const Icon(
                      Icons.cancel,
                    ),
                    onDeleted: () {
                      setState(() {
                        filteredProducts.clear();
                        _allOrdersLoaded = false;
                        isSearchapplied = false;
                        searchQuery = '';
                        page = 1;
                        fetchProductData();
                      });
                    },
                  ),
                const Gap(3),
                if (barCodeFilter.isNotEmpty)
                  Chip(
                    label: Text(
                      'Barcode applied',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 124, 124, 124),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    deleteIcon: const Icon(
                      Icons.cancel,
                    ),
                    onDeleted: () {
                      setState(() {
                        filteredProducts.clear();
                        _allOrdersLoaded = false;
                        barCodeFilter = '';
                        page = 1;
                        isfilterapplied = checkFilterAppliedOrNot();
                        fetchProductData();
                      });
                    },
                  ),
                const Gap(3),
                if (isSortapplied)
                  Chip(
                    label: Text(
                      (selectedSortData == 'updatedAt' && order == 'asc')
                          ? 'Oldest Updated'
                          : (selectedSortData == 'updatedAt' && order == 'desc')
                              ? 'Recently Updated'
                              : (selectedSortData == 'createdAt' &&
                                      order == 'asc')
                                  ? 'Oldest Created'
                                  : (selectedSortData == 'createdAt' &&
                                          order == 'desc')
                                      ? 'Recently Created'
                                      : (selectedSortData == 'avgRating' &&
                                              order == 'asc')
                                          ? 'Rating (Low to High)'
                                          : 'Rating (High to Low)',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 124, 124, 124),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    deleteIcon: const Icon(
                      Icons.cancel,
                    ),
                    onDeleted: () {
                      setState(() {
                        filteredProducts.clear();
                        _allOrdersLoaded = false;
                        isSortapplied = false;
                        selectedSortData = '';
                        page = 1;
                        fetchProductData();
                      });
                    },
                  ),
                const Gap(3),
                if (isfilterapplied && categories.isNotEmpty)
                  Chip(
                    label: Text(
                      'Category: $categories',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 124, 124, 124),
                        fontSize: 13,
                      ),
                    ),
                    deleteIcon: const Icon(
                      Icons.cancel,
                    ),
                    onDeleted: () {
                      setState(() {
                        filteredProducts.clear();
                        _allOrdersLoaded = false;
                        categories = '';
                        subCategories = [];
                        page = 1;
                        isfilterapplied = checkFilterAppliedOrNot();
                        fetchProductData();
                        ;
                      });
                    },
                  ),
                const Gap(3),
                if (isfilterapplied && subCategories.isNotEmpty)
                  for (var item in subCategories)
                    Chip(
                      label: Text(
                        item,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 124, 124, 124),
                          fontSize: 12,
                        ),
                      ),
                      deleteIcon: const Icon(
                        Icons.cancel,
                      ),
                      onDeleted: () {
                        setState(() {
                          filteredProducts.clear();
                          _allOrdersLoaded = false;
                          subCategories.remove(item);
                          page = 1;
                          fetchProductData();
                        });
                      },
                    ),
                const Gap(3),
                if (isfilterapplied && creatorPhone.isNotEmpty)
                  Chip(
                    label: Text(
                      'Creator- $creatorName',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 124, 124, 124),
                        fontSize: 12,
                      ),
                    ),
                    deleteIcon: const Icon(
                      Icons.cancel,
                    ),
                    onDeleted: () {
                      setState(() {
                        filteredProducts.clear();
                        _allOrdersLoaded = false;
                        creatorName = '';
                        creatorPhone = '';
                        page = 1;
                        isfilterapplied = checkFilterAppliedOrNot();
                        fetchProductData();
                      });
                    },
                  ),
                const Gap(3),
                if (isfilterapplied &&
                    (startDate.isNotEmpty || endDate.isNotEmpty))
                  Chip(
                    label: Text(
                      '$startDate - $endDate',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 124, 124, 124),
                        fontSize: 12,
                      ),
                    ),
                    deleteIcon: const Icon(
                      Icons.cancel,
                    ),
                    onDeleted: () {
                      setState(() {
                        filteredProducts.clear();
                        _allOrdersLoaded = false;
                        startDate = '';
                        endDate = '';
                        page = 1;
                        isfilterapplied = checkFilterAppliedOrNot();
                        fetchProductData();
                      });
                    },
                  ),
                const Gap(3),
              ],
            ),
        ],
      ),
    );
  }

  void handleProductData() {
    scrollController.addListener(
      () async {
        if (scrollController.position.maxScrollExtent ==
            scrollController.position.pixels) {
          fetchProductData();
        }
      },
    );
  }

  void deleteProductById(String productId) async {
    String message = await moveToRecyclyeBin(context, productId);
    Navigator.pop(context);

    if (message == 'success')
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Moved to recycle bin'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.greenAccent.shade400,
        ),
      );
    else
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    refreshScreen();
  }

  void fetchProductData() async {
    if (isLoading || _allOrdersLoaded) return;
    try {
      setState(() {
        isLoading = true;
        if (scroll) {
          page = page + 1;
        }
      });
      String subCategory = '';
      for (String subcategory in subCategories) {
        subCategory += ('&subCategory1[]=${Uri.encodeComponent(subcategory)}');
      }

      print('''.

https://api.pehchankidukan.com/admin/products/searchProducts?searchQuery=$searchQuery&pageNo=$page&sortBy=$selectedSortData&sortType=$order&category=${Uri.encodeComponent(categories)}$subCategory&adminPhone=$creatorPhone&startDate=$startDate&endDate=$endDate&barCodeFilter=$barCodeFilter


.''');

      final url =
          "https://api.pehchankidukan.com/admin/products/searchProducts?searchQuery=$searchQuery&pageNo=$page&sortBy=$selectedSortData&sortType=$order&category=${Uri.encodeComponent(categories)}$subCategory&adminPhone=$creatorPhone&startDate=$startDate&endDate=$endDate&barCodeFilter=$barCodeFilter";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        ProductModel productModel =
            ProductModel.fromJson(jsonDecode(response.body));

        if (productModel.message == "Global Products") {
          filteredProducts = filteredProducts + (productModel.products!);

          if (productModel.products!.isNotEmpty) {
            setState(() {
              page = page + 1;
              isLoading = false;
              totalResultsFound = productModel.totalOrders!;
            });
          }
          if (productModel.products!.length < 10) {
            setState(() {
              _allOrdersLoaded = true;
              isLoading = false;
            });
          }
        }
      } else {
        setState(() {
          filteredProducts = [];
          isLoading = false;
          totalResultsFound = 0;
        });
      }
    } catch (e, stackTrace) {
      print('Aaaaa error : $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> refreshScreen() async {
    print('Refreh screen called ');
    setState(() {
      filteredProducts.clear();
      page = 1;
      _allOrdersLoaded = false;
      fetchProductData();
    });
  }

  String? formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    String formattedTime = DateFormat('h:mm a', 'en_US').format(dateTime);
    return '$formattedDate $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(
              pageIndex: 0,
            ),
          ),
        );

        return false;
      },
      child: Scaffold(
        endDrawer: const AppDrawer(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: RawMaterialButton(
          onPressed: () async {
            String refresh = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddProductScreen(),
              ),
            );
            if (refresh == 'refresh') {
              refreshScreen();
            }
          },
          elevation: 3.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

          fillColor: Colors.blue,
          // focusColor: Colors.blue,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(15),
              Text(
                'Add Product',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              Gap(5),
              Icon(
                Icons.add,
                color: Colors.white,
                size: 25,
              ),
              Gap(15),
            ],
          ),
        ),
        resizeToAvoidBottomInset: false,
        appBar: CommonAppBar(
          showBackButton: false,
          title: 'Products',
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  isDense: true,
                  labelText: 'Search products by name',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                onChanged: (value) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    setState(() {
                      value == ''
                          ? isSearchapplied = false
                          : isSearchapplied = true;
                      page = 1;
                      searchQuery = value;
                    });
                    refreshScreen();
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Gap(10),
                Expanded(
                  child: GestureDetector(
                    //sort
                    onTap: () async {
                      String sortStatus = await showDialog(
                        context: context,
                        builder: (context) {
                          return SortDialogBox(
                            selectedSortData: selectedSortData,
                            order: order,
                          );
                        },
                      );
                      setState(() {
                        if (sortStatus == 'avgRatingLH') {
                          isSortapplied = true;
                          selectedSortData = 'avgRating';
                          order = 'asc';
                          page = 1;
                        } else if (sortStatus == 'oldestCreated') {
                          isSortapplied = true;
                          selectedSortData = 'createdAt';
                          page = 1;
                          order = 'asc';
                        } else if (sortStatus == 'oldestUpdated') {
                          isSortapplied = true;
                          selectedSortData = 'updatedAt';
                          page = 1;
                          order = 'asc';
                        } else if (sortStatus.isNotEmpty) {
                          isSortapplied = true;
                          selectedSortData = sortStatus;
                          page = 1;
                          order = 'desc';
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Sort type not selected')));
                        }
                      });
                      if (sortStatus.isNotEmpty) refreshScreen();
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Gap(25),
                          Container(
                            width: 17,
                            height: 17,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/sort.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const Gap(10),
                          Text(
                            "Sort",
                            style:
                                GoogleFonts.lato(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                Expanded(
                  //filter
                  child: GestureDetector(
                    onTap: () async {
                      final result = await showModalBottomSheet(
                        context: context,
                        builder: (context) => FilterOptions(
                          list: subCategories,
                          str: categories,
                          passedCreatorPhone: creatorPhone,
                          passedStartDate: startDate,
                          passedEndDate: endDate,
                          barCodeFilter: barCodeFilter,
                        ),
                      );
                      if (result != null) {
                        objects = result;
                        setState(() {
                          categories = objects[0];
                          subCategories = objects[1];
                          creatorPhone = objects[2];
                          creatorName = objects[3];
                          startDate = objects[4];
                          endDate = objects[5];
                          barCodeFilter = objects[6];
                          isfilterapplied =
                              objects.any((obj) => obj.isNotEmpty);
                          page = 1;
                        });
                        refreshScreen();
                      }
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Gap(15),
                          Container(
                            width: 17,
                            height: 17,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/filter.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Gap(15),
                          Text(
                            "Filter",
                            style:
                                GoogleFonts.lato(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(10),
              ],
            ),
            const Gap(5),
            Row(
              children: [
                Gap(20),
                Text(
                  '${isLoading ? 'Finding match ... ' : '$totalResultsFound Prodcuts found'}',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Gap(5),
            buildresultheader(filteredProducts),
            (isLoading && filteredProducts.isEmpty)
                ? Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Lottie.asset(
                            'assets/images/loading.json',
                            width: 200,
                            height: 200,
                          ),
                        ),
                      ],
                    ),
                  )
                : filteredProducts.isEmpty
                    ? buildNoResultheader(filteredProducts)
                    : Expanded(
                        child: LiquidPullToRefresh(
                          animSpeedFactor: 10,
                          showChildOpacityTransition: false,
                          height: 60,
                          onRefresh: refreshScreen,
                          color: Colors.amber,
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            controller: scrollController,
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 10),
                                  itemCount: filteredProducts.length + 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index < filteredProducts.length) {
                                      var productData = filteredProducts[index];
                                      return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProductDetailsScreen(
                                                        id: productData.id),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            elevation: 1,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0,
                                                  bottom: 8.0,
                                                  left: 2,
                                                  right: 2),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 110,
                                                    width: 100,
                                                    child: ClipRRect(
                                                      child: productData
                                                                  .mainImage !=
                                                              null
                                                          ? productData
                                                                  .mainImage!
                                                                  .isEmpty
                                                              ? Image.asset(
                                                                  'assets/images/NoImageAvailable.jpg')
                                                              : Image(
                                                                  fit: BoxFit
                                                                      .contain,
                                                                  image:
                                                                      NetworkImage(
                                                                    productData
                                                                        .mainImage!,
                                                                  ),
                                                                )
                                                          : Image.asset(
                                                              'assets/images/NoImageAvailable.jpg'),
                                                    ),
                                                  ),
                                                  const Gap(10),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                ' ${productData.productName}',
                                                                softWrap: true,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 2,
                                                                style:
                                                                    GoogleFonts
                                                                        .lato(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const Gap(8),
                                                        Text(
                                                          '${formatDateTime(productData.createdAt)}',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 13),
                                                        ),
                                                        const Gap(8),
                                                        RichText(
                                                          maxLines: 2,
                                                          softWrap: true,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: productData
                                                                    .category,
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    ' › ${productData.subCategory1}',
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    ' › ${productData.subCategory2}',
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                children: [
                                                                  const Icon(
                                                                    Icons.star,
                                                                    color: Colors
                                                                        .amber,
                                                                    size: 18,
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 3),
                                                                  Text(
                                                                    productData
                                                                        .avgRating
                                                                        .toString(),
                                                                    style:
                                                                        GoogleFonts
                                                                            .lato(
                                                                      color: Colors
                                                                          .black54,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                String refresh =
                                                                    await Navigator
                                                                        .push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            EditProductScreen(
                                                                      productId:
                                                                          productData
                                                                              .id,
                                                                    ),
                                                                  ),
                                                                );
                                                                if (refresh ==
                                                                    "refresh") {
                                                                  refreshScreen();
                                                                }
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                elevation: 0.0,
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              7.0), // Match corner radius
                                                                ),
                                                              ),
                                                              // child: Icon(
                                                              //   Icons.edit,
                                                              //   color:
                                                              //       Colors.blue,
                                                              // ),
                                                              child: Text(
                                                                "Edit",
                                                                style:
                                                                    GoogleFonts
                                                                        .lato(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .blue,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialog(
                                                                      title:
                                                                          Text(
                                                                        'Move to recycle bin',
                                                                        style: GoogleFonts
                                                                            .lato(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      content:
                                                                          SingleChildScrollView(
                                                                        child:
                                                                            ListBody(
                                                                          children: <Widget>[
                                                                            Text(
                                                                              'Are you sure you want to move this product to recycle bin ?',
                                                                              style: GoogleFonts.lato(),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      actions: <Widget>[
                                                                        TextButton(
                                                                          child:
                                                                              Text(
                                                                            'Cancel',
                                                                            style:
                                                                                GoogleFonts.lato(
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        ),
                                                                        TextButton(
                                                                          child:
                                                                              Text(
                                                                            'Delete',
                                                                            style:
                                                                                GoogleFonts.lato(
                                                                              color: Colors.red,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            deleteProductById(productData.id);
                                                                          },
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                elevation: 0.0,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              7.0), // Match corner radius
                                                                ),
                                                              ),
                                                              // child: Icon(
                                                              //   Icons.delete,
                                                              //   color:
                                                              //       Colors.red,
                                                              // ),
                                                              child: Text(
                                                                "Delete",
                                                                style:
                                                                    GoogleFonts
                                                                        .lato(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ));
                                    } else if (_allOrdersLoaded &&
                                        index == filteredProducts.length) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10.0,
                                              right: 10,
                                              left: 10,
                                              bottom: 20),
                                          child: Text(
                                            'No more products to show',
                                            style: GoogleFonts.lato(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  },
                                ),
                                const Gap(100),
                              ],
                            ),
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
