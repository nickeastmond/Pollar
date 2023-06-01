import 'dart:core';

import 'package:flutter/material.dart';
import 'package:pollar/polls_theme.dart';
import 'package:pollar/services/feeds/participation_history_provider.dart';

import 'package:provider/provider.dart';

import '../../polls/poll_card.dart';



class ParticipationHistoryPage extends StatefulWidget {
  const ParticipationHistoryPage({super.key});
  @override
  State<ParticipationHistoryPage> createState() => _ParticipationHistoryPageState();
  
}

class _ParticipationHistoryPageState extends State<ParticipationHistoryPage> with WidgetsBindingObserver {
  bool refresh = false;

  final ScrollController _scrollController = ScrollController();

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose(); // Call super method
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ParticipationHistoryProvider>(
      builder: (_, provider, __) {
        return PollsTheme(
          builder: (context, theme) {
            return Scaffold(
                backgroundColor: MediaQuery.of(context).platformBrightness ==
                        Brightness.light
                    ? Colors.white
                    : const Color.fromARGB(255, 25, 25, 25),
                body: RefreshIndicator(
                    triggerMode: RefreshIndicatorTriggerMode.onEdge,
                    color: theme.secondaryHeaderColor,
                    onRefresh: () => provider.fetchInitial(100),
                    child: 
                    provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(), // Loading indicator
                      ) :
                    provider.items.isNotEmpty 
                        ? ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            shrinkWrap: false,
                            itemCount: provider.items.length,
                            itemBuilder: (_, int index) {
                              

                              final pollItem = provider.items[index];

                              if (index == 0) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 6, bottom: 0, left: 8, right: 8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark
                                              ? theme.primaryColor
                                              : theme.cardColor,
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 10,
                                                spreadRadius: 0),
                                          ],
                                        ),
                                        height: 50,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0,
                                          right: 8.0,
                                          top: 8,
                                          bottom: 0),
                                      child: PollCard(
                                          poll: pollItem,
                                          feedProvider: provider),
                                    ),
                                  ],
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0, top: 8, bottom: 0),
                                child: PollCard(
                                  poll: pollItem,
                                  feedProvider: provider,
                                ),
                              );
                            },
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 6, bottom: 0, left: 8, right: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? theme.primaryColor
                                          : theme.cardColor,
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 10,
                                            spreadRadius: 0),
                                      ],
                                    ),
                                    height: 50,
                                   
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height,
                                )
                              ],
                            ),
                          )));
          },
        );
      },
    );
  }
}
