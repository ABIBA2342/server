import os
import random
import requests
import asyncio
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import threading
from aiogram import Bot, Dispatcher, types
from aiogram.filters import Command
from aiogram.utils.keyboard import InlineKeyboardBuilder

BOT_TOKEN = os.environ.get("9090266003:AAFd6wj7Wb_cFbpakRQPFYN1E9sTkN0u0gg")
SERVER_IP = "31.77.159.85"
PORT = "2398"

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()

user_numbers = {}

@dp.message(Command("start"))
async def cmd_start(message: types.Message):
    builder = InlineKeyboardBuilder()
    builder.button(text="📱 Получить номер +7", callback_data="get_number")
    await message.answer(
        "Добро пожаловать в SketchGram!\n\n"
        "Нажмите на кнопку ниже, чтобы получить свободный номер и инструкцию по входу.",
        reply_markup=builder.as_markup()
    )

@dp.callback_query(lambda c: c.data == "get_number")
async def process_get_number(callback: types.CallbackQuery):
    chat_id = callback.from_user.id
    random_num = f"+79{random.randint(100000000, 999999999)}"
    user_numbers[random_num] = str(chat_id)
    
    text = (
        f"✅ Ваш номер: <b>{random_num}</b>\n\n"
        f"<b>Как войти:</b>\n"
        f"1. Откройте приложение SketchGram (APK).\n"
        f"2. Введите этот номер.\n"
        f"3. Ждите код. Он придет сюда, в этот чат!\n\n"
        f"<i>Сервер: {SERVER_IP}:{PORT}</i>"
    )
    
    # Исправленная строка для aiogram 3
    await callback.message.edit_text(
        text=text, 
        parse_mode="HTML", 
        reply_markup=None
    )
    await callback.answer()

class WebhookHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        
        try:
            data = json.loads(post_data)
            phone = data.get("phone", "")
            code = data.get("code", data.get("otp", ""))
            
            if phone in user_numbers:
                chat_id = user_numbers[phone]
                loop = asyncio.new_event_loop()
                asyncio.set_event_loop(loop)
                loop.run_until_complete(
                    bot.send_message(
                        chat_id=chat_id, 
                        text=f"🔐 <b>Ваш код входа:</b> {code}\n\n<i>Введите его в приложении.</i>",
                        parse_mode="HTML"
                    )
                )
                loop.close()
                print(f"Код {code} отправлен для {phone} в чат {chat_id}", flush=True)
            else:
                print(f"Номер {phone} не найден в базе! Доступные: {list(user_numbers.keys())}", flush=True)
                
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK")
        except Exception as e:
            print(f"Ошибка вебхука: {e}", flush=True)
            self.send_response(500)
            self.end_headers()

def run_webhook():
    server = HTTPServer(('0.0.0.0', 8080), WebhookHandler)
    print("Вебхук сервер запущен на порту 8080...", flush=True)
    server.serve_forever()

async def main():
    threading.Thread(target=run_webhook, daemon=True).start()
    print("Бот запущен и слушает Telegram...", flush=True)
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
