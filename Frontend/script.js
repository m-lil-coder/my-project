document.addEventListener("DOMContentLoaded", () => {
    const userList = document.getElementById('user-list');
    const addUserForm = document.getElementById('add-user-form');

    // Fetch all users
    fetch('http://backend:5000/api/users')
        .then(response => response.json())
        .then(users => {
            users.forEach(user => {
                const listItem = document.createElement('li');
                listItem.textContent = `${user.name} - ${user.email}`;
                userList.appendChild(listItem);
            });
        });

    // Handle form submission
    addUserForm.addEventListener('submit', function(event) {
        event.preventDefault();

        const name = document.getElementById('name').value;
        const email = document.getElementById('email').value;

        const newUser = {
            name: name,
            email: email
        };

        fetch('http://backend:5000/api/users', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(newUser)
        })
        .then(response => response.json())
        .then(user => {
            const listItem = document.createElement('li');
            listItem.textContent = `${user.name} - ${user.email}`;
            userList.appendChild(listItem);
            document.getElementById('name').value = '';
            document.getElementById('email').value = '';
        });
    });
});
