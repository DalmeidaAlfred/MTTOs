from flask import Flask, request, render_template_string

app = Flask(__name__)

# List to store ticket details as dictionaries
ticket_list = []

@app.route('/alert', methods=['POST'])
def alert():
    data = request.get_json()
    urgency = data.get('urgency')
    
    # Get the new ticket information
    ticket_info = {
        "ticket_id": data.get('ticket_id'),
        "subject": data.get('subject'),
        "contact_email": data.get('contact_email'),
        "contact_name": data.get('contact_name')
    }
    
    # Add the ticket info to the list
    ticket_list.append(ticket_info)
    
    if urgency == "4":
        # Trigger alert (for example, send notification to TV)
        return {"status": "Alert triggered"}, 200
    else:
        return {"status": "No alert triggered"}, 200

@app.route('/tickets', methods=['GET'])
def get_tickets():
    # Render a simple HTML page to display the ticket list
    return render_template_string('''
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Ticket List</title>
        <style>
            body { font-family: Arial, sans-serif; }
            h1 { text-align: center; }
            ul { list-style-type: none; padding: 0; }
            li { padding: 8px; border-bottom: 1px solid #ccc; }
        </style>
        <script>
            function fetchTickets() {
                fetch('/tickets/data')
                    .then(response => response.json())
                    .then(data => {
                        const ticketList = document.getElementById('ticket-list');
                        ticketList.innerHTML = ''; // Clear existing list
                        data.tickets.forEach(ticket => {
                            const li = document.createElement('li');
                            li.innerHTML = `
                                <strong>Ticket ID:</strong> ${ticket.ticket_id}<br>
                                <strong>Subject:</strong> ${ticket.subject}<br>
                                <strong>Contact Name:</strong> ${ticket.contact_name}<br>
                                <strong>Contact Email:</strong> ${ticket.contact_email}
                            `;
                            ticketList.appendChild(li);
                        });
                    })
                    .catch(error => console.error('Error fetching tickets:', error));
            }

            // Poll for new tickets every 5 seconds
            setInterval(fetchTickets, 5000);
            // Initial fetch to populate the list immediately
            window.onload = fetchTickets;
        </script>
      </head>
      <body>
        <h1>Ticket List</h1>
        <ul id="ticket-list">
          {% for ticket in tickets %}
            <li>
                <strong>Ticket ID:</strong> {{ ticket.ticket_id }}<br>
                <strong>Subject:</strong> {{ ticket.subject }}<br>
                <strong>Contact Name:</strong> {{ ticket.contact_name }}<br>
                <strong>Contact Email:</strong> {{ ticket.contact_email }}
            </li>
          {% endfor %}
        </ul>
      </body>
    </html>
    ''', tickets=ticket_list)

@app.route('/tickets/data', methods=['GET'])
def get_tickets_data():
    return {'tickets': ticket_list}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
