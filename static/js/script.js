document.addEventListener('DOMContentLoaded', function () {
    const input = document.getElementById('districtSelect');
    const dropdown = document.getElementById('districtDropdown');
    const dataSection = document.getElementById('districtData');

    function filterDistricts() {
        const query = input.value;
        if (query.length < 1) {
            dropdown.style.display = 'none';
            return;
        }

        fetch(`/search_districts?q=${query}`)
            .then(response => response.json())
            .then(data => {
                dropdown.innerHTML = '';
                if (data.length > 0) {
                    data.forEach(district => {
                        const div = document.createElement('div');
                        div.textContent = district;
                        div.onclick = () => selectDistrict(district);
                        dropdown.appendChild(div);
                    });
                    dropdown.style.display = 'block';
                } else {
                    dropdown.style.display = 'none';
                }
            })
            .catch(error => console.error('Error:', error));
    }

    function selectDistrict(district) {
        input.value = district;
        dropdown.style.display = 'none';
        // Example: Fetch and display data for the selected district
        dataSection.innerHTML = `<p>Selected District: ${district}</p><p>Area Data Loading...</p>`;
        dataSection.style.display = 'block';
        // Here you can add an AJAX call to fetch specific data for the district
        // For now, just showing the selection
    }

    input.addEventListener('blur', () => {
        setTimeout(() => dropdown.style.display = 'none', 200);
    });

    input.addEventListener('keyup', filterDistricts);
});
