import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view.dart';

class ChatPanel extends StatelessWidget {
  const ChatPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final meetingController = Get.find<MeetingController>();
    final messageController = TextEditingController();
    final scrollController = ScrollController();

    return Container(
      decoration: BoxDecoration(
        color: Get.isDarkMode ? const Color(0xFF303134) : Colors.white,
        border: Border(
          left: BorderSide(
            color: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          ),
        ),
      ),
      child: Column(
        children: [
          // Chat header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Meeting chat',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => meetingController.toggleChat(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: Obx(() {
              // Scroll to bottom when new messages arrive
              if (meetingController.chatMessages.isNotEmpty &&
                  scrollController.hasClients) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                });
              }

              return meetingController.chatMessages.isEmpty
                  ? Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(
                        color:
                            Get.isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                      ),
                    ),
                  )
                  : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: meetingController.chatMessages.length,
                    itemBuilder: (context, index) {
                      final message = meetingController.chatMessages[index];
                      final isMe =
                          message.senderId == Get.find<AuthController>().userId;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment:
                              isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  message.senderName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color:
                                        Get.isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isMe
                                        ? Get.theme.primaryColor
                                        : Get.isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    message.message,
                                    style: TextStyle(
                                      color:
                                          isMe
                                              ? Colors.white
                                              : Get.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    message.formattedTime,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          isMe
                                              ? Colors.white.withOpacity(0.7)
                                              : Get.isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
            }),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? const Color(0xFF303134) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        meetingController.sendChatMessage(value);
                        messageController.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Get.theme.primaryColor),
                  onPressed: () {
                    final message = messageController.text.trim();
                    if (message.isNotEmpty) {
                      meetingController.sendChatMessage(message);
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
