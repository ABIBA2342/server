import os
import random
import asyncio
import json
from aiohttp import web
from aiogram import Bot, Dispatcher, types
from aiogram.filters import Command
from aiogram.utils.keyboard import InlineKeyboardBuilder

# ВСТАВЬ СВОЙ НОВЫЙ ТОКЕН СЮДА:
BOT_TOKEN = "9040774487:AAGHYsh-8T9y7CCdaqcElOLWYsMdbYLzdL0" 
SERVER_IP = "31.77.159.85"
PORT = "2398"

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()

user_numbers = {}
user_phones = {}

@dp.message(Command("start"))
async def cmd_start(message: types.Message):
    chat_id = str(message.from_user.id)
    
    if chat_id in user_phones:
        phone = user_phones[chat_id]
        await message.answer(
            f"Вы уже зарегистрированы в SummerGram!\n\n"
            f"Ваш номер: <b>{phone}</b>\n\n"
            f"<i>Сервер: {SERVER_IP}:{PORT}</i>",
            parse_mode="HTML"
        )
        return

    builder = InlineKeyboardBuilder()
    builder.button(text="📱 Получить номер +7", callback_data="get_number")
    await message.answer(
        "Добро пожаловать в SummerGram!\n\n"
        "Нажмите на кнопку ниже, чтобы получить свободный номер и инструкцию по входу.",
        reply_markup=builder.as_markup()
    )

@dp.callback_query(lambda c: c.data == "get_number")
async def process_get_number(callback: types.CallbackQuery):
    chat_id = str(callback.from_user.id)
    
    if chat_id in user_phones:
        await callback.answer("У вас уже есть номер! Проверьте сообщения.", show_alert=True)
        return
        
    random_num = f"+79{random.randint(100000000, 999999999)}"
    user_numbers[random_num] = chat_id
    user_phones[chat_id] = random_num
    
    text = (
        f"✅ Ваш номер в SummerGram: <b>{random_num}</b>\n\n"
        f"<b>Как войти:</b>\n"
        f"1. Откройте приложение SummerGram (APK).\n"
        f"2. Введите этот номер.\n"
        f"3. Ждите код. Он придет сюда, в этот чат!\n\n"
        f"<i>Сервер: {SERVER_IP}:{PORT}</i>"
    )
    await callback.message.answer(text=text, parse_mode="HTML")
    await callback.message.edit_reply_markup(reply_markup=None)
    await callback.answer()

async def handle_webhook(request):
    try:
        data = await request.json()
        phone = data.get("phone", "")
        code = data.get("code", data.get("otp", ""))
        
        if phone in user_numbers:
            chat_id = user_numbers[phone]
            await bot.send_message(
                chat_id=chat_id, 
                text=f"🔐 <b>Ваш код входа в SummerGram:</b> {code}\n\n<i>Введите его в приложении.</i>",
                parse_mode="HTML"
            )
            print(f"Код {code} отправлен для {phone} в чат {chat_id}", flush=True)
        else:
            print(f"Номер {phone} не найден в базе!", flush=True)
            
        return web.Response(text="OK")
    except Exception as e:
        print(f"Ошибка вебхука: {e}", flush=True)
        return web.Response(status=500)

async def main():
    app = web.Application()
    app.router.add_post('/', handle_webhook)
    runner = web.AppRunner(app)
    await runner.setup()
    site = web.TCPSite(runner, '0.0.0.0', 8080)
    await site.start()
    print("Вебхук сервер запущен на порту 8080...", flush=True)
    
    print("Бот запущен и слушает Telegram...", flush=True)
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
