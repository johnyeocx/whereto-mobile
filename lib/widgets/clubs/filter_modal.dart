import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:where_to/providers/user_provider.dart';

import '../../providers/clubs_provider.dart';
import '../../providers/filters_provider.dart';
import '../app_text.dart';

class FilterModal extends StatefulWidget {
  const FilterModal({Key? key}) : super(key: key);

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  _filterOptionChanged(int index) async {
    final filterModel = Provider.of<Filters>(context, listen: false);

    context.read<Filters>().setFilterOption(index: index);

    final clubModel = Provider.of<ClubsProvider>(context, listen: false);
    await clubModel.setClubs(
        index,
        context.read<UserProvider>().user!.location!,
        filterModel.showLikedOnly);
  }

  _toggleShowLikedOnly(bool? value) async {
    final filterModel = Provider.of<Filters>(context, listen: false);
    filterModel.toggleShowLikedOnly();

    if (value == null) return;

    final clubModel = Provider.of<ClubsProvider>(context, listen: false);
    await clubModel.setClubs(filterModel.filterOption.index,
        context.read<UserProvider>().user!.location!, value);
  }

  @override
  Widget build(BuildContext context) {
    Color likedColor = const Color(0xFFFFCFCF);
    Color optionsColor = const Color(0xffEAC9FF);
    Color insetColor = const Color.fromARGB(255, 107, 107, 107);

    List<String> filterOptions = [
      "Likes",
      "Queue Time",
      "Current Genre",
      "Energy Levels",
      "Ratio"
    ];

    return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(color: Color.fromARGB(255, 32, 32, 32)),
        padding: const EdgeInsets.all(20),
        child: Center(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const AppTextHeader(
              text: "Find the right club, for you.",
              fontSize: 22,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  SizedBox(
                    width: 20,
                    child: FaIcon(FontAwesomeIcons.wineGlass,
                        color: likedColor, size: 18),
                  ),
                  const SizedBox(width: 15),
                  AppText(
                    text: "Show Liked Only",
                    color: likedColor,
                    fontSize: 20,
                  ),
                ]),
                Transform.scale(
                  scale: 1,
                  child: Checkbox(
                      side: MaterialStateBorderSide.resolveWith(
                        (states) => BorderSide(width: 2.0, color: likedColor),
                      ),
                      activeColor: likedColor,
                      checkColor: const Color.fromARGB(255, 32, 32, 32),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      value: context.watch<Filters>().showLikedOnly,
                      onChanged: (value) {
                        _toggleShowLikedOnly(value);
                      }),
                )
              ],
            ),
            Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 1.5,
                decoration: BoxDecoration(color: insetColor)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                SizedBox(
                    width: 20,
                    child: FaIcon(FontAwesomeIcons.filter,
                        color: optionsColor, size: 16)),
                const SizedBox(width: 15),
                AppText(
                  text: "Filter By",
                  color: optionsColor,
                  fontSize: 20,
                ),
              ]),
            ),
            Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 1.5,
                decoration: BoxDecoration(color: insetColor)),
            const SizedBox(height: 20),
            ListView.builder(
                shrinkWrap: true,
                itemCount: filterOptions.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                      height: 40,
                      child: TextButton(
                        style: TextButton.styleFrom(primary: optionsColor),
                        onPressed: () {
                          _filterOptionChanged(index);
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(filterOptions[index],
                              style: GoogleFonts.nunito(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                  color: context
                                              .watch<Filters>()
                                              .filterOption
                                              .index ==
                                          index
                                      ? optionsColor
                                      : const Color.fromARGB(
                                          255, 210, 210, 210),
                                  letterSpacing: -0.5)),
                        ),
                      ));
                })
          ]),
        ));
  }
}
