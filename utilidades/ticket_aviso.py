from flask import Flask, request, render_template
import pygame
import requests
import random

app_tickets = Flask(__name__)

# Initialize pygame mixer
pygame.mixer.init()

# Define pairs for good and bad events
good_pairs = [
    ("/home/pi/tickets_urgentes/sounds/good_sound1.mp3", "success_image1.png"),
    ("/home/pi/tickets_urgentes/sounds/good_sound2.mp3", "success_image2.png")
]

bad_pairs = [
    ("/home/pi/tickets_urgentes/sounds/bad_sound1.mp3", "alert_image1.png"),
    # Add more bad sound-image pairs here if needed
]

ticket_list = []
previous_state_code = 0

def play_and_display_pair(is_good):
    if is_good:
        sound, image = random.choice(good_pairs)
    else:
        sound, image = random.choice(bad_pairs)
    
    # Play the corresponding sound
    pygame.mixer.music.load(sound)
    pygame.mixer.music.play()

    # Return the corresponding image
    return image

@app_tickets.route('/get_tickets', methods=['GET'])
def get_tickets():
    global previous_state_code
    show_image = ""

    # Obtain tickets data
    response = requests.get("https://flows.alfredsmartdata.com/webhook/tickets-urgentes", headers={"Content-Type": "application/json"})
    
    # Got tickets (200 OK)
    if response.status_code == 200:
        ticket_data = response.json()  # Process data as JSON
        prev_ticket_length = len(ticket_list)
        ticket_list.clear()  # Clear the ticket list
        ticket_list.extend(ticket_data)  # Add all tickets
        ticket_list.reverse()  # Last in, first out
        ticket_length = len(ticket_list)
        ticket_diff = ticket_length - prev_ticket_length
        
        # Check for new or closed tickets
        if ticket_diff >= 1:
            show_image = play_and_display_pair(is_good=False)  # Bad pair for new tickets
        elif ticket_diff < 0:
            show_image = play_and_display_pair(is_good=True)  # Good pair for closed tickets
        else:
            show_image = ""  # No image to display

        previous_state_code = 200
    elif response.status_code == 204:
        ticket_list.clear()
        
        if previous_state_code == 200:
            show_image = play_and_display_pair(is_good=True)  # Good pair for no tickets
        else:
            show_image = ""  # No image to display

        previous_state_code = 204

    return render_template("base.html", lista_tickets=ticket_list, show_image=show_image, status_code=response.status_code)

if __name__ == '__main__':
    app_tickets.run(host='0.0.0.0', port=5200)
